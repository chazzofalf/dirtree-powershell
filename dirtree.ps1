class XFileReadEnumerable__ : object,System.Collections.IEnumerable
{
    hidden [XFileInfo] $owner
    XFileReadEnumerable__([XFileInfo]$owner)
    {
        $this.owner=$owner
        
    }
    
    [System.Collections.IEnumerator] GetEnumerator()
    {
        return [XFileReadEnumerator]::new($this.owner)
    }
}
class XFileReadEnumerable : XFileReadEnumerable__,System.Collections.Generic.IEnumerable[byte]
{
    
    XFileReadEnumerable([XFileInfo]$owner) : base($owner) {}

    [System.Collections.Generic.IEnumerator[System.Byte]] GetEnumerator()
    {
        return [XFileReadEnumerator]::new($this.owner)
    }
    
    
}
class XFileReadEnumerator__ : object,System.Collections.IEnumerator
{
    hidden [byte] $xcurrent
    hidden [bool] $hasCurrent
    hidden [int] $blockIndex
    hidden [byte[]] $block
    hidden [XFileInfo] $xFileInfo
    hidden [System.IO.FileStream] $fileStream
    hidden [bool] $eof
    XFileReadEnumerator__([XFileInfo]$xFileInfo)
    {
        $this.xFileInfo=$xFileInfo
        
    }
    [object] get_Current()
    {
        if ($this.hasCurrent)
        {
            
            return $this.xcurrent
        }
        return $null
    }
    [bool] MoveNext()
    {
        if ($this.eof)
        {
            return $false
        }
        if ($null -eq $this.fileStream)
        {
            $this.fileStream = [System.IO.FileStream]::new($this.xFileInfo)
        }
        return $false
    }
    [void] Reset()
    {
        
    }
    [void] Dispose()
    {
        
    }
}
class XFileReadEnumerator : XFileReadEnumerator__,System.Collections.Generic.IEnumerator[byte]
{
    XFileReadEnumerator([XFileInfo]$xFileInfo) : base($xFileInfo)
    {

    }
    [byte]get_Current()
    {
        return $null
    }
    [bool] MoveNext()
    {
        return $false
    }
    [void] Reset()
    {

    }
    [void] Dispose()
    {

    }
}

class XFileInfo {
    hidden [string] $_path
    hidden [System.Collections.ArrayList] $_props
    hidden [void] InitializePath([string]$path)
    {
        if (([System.IO.File]::GetAttributes($path) -band [System.IO.FileAttributes]::Directory) -eq [System.IO.FileAttributes]::Directory)
        {            
            $this._path = [System.IO.DirectoryInfo]::new($path).FullName
        }
        else {
            $this._path = [System.IO.FileInfo]::new($path).FullName
        }
    }
    [string] GetPath()
    {
        return $this._path
    }
    [string] GetName()
    {
        return [System.IO.Path]::GetFileName($this._path)
    }
    [bool] GetIsDirectory()
    {
        return ([System.IO.File]::GetAttributes($this._path) -band [System.IO.FileAttributes]::Directory) -eq [System.IO.FileAttributes]::Directory
    }
    [long] GetLength()
    {
        if ($this.GetIsDirectory())
        {
            return $this.GetSubItemCount()
        }
        else {
            return [System.IO.FileInfo]::new($this._path).Length
        }
    }

    [System.Collections.Generic.IEnumerable[XFileInfo]] GetSubitems()
    {    
        
        [System.Collections.Generic.IEnumerable[XFileInfo]] $output = [System.Linq.Enumerable]::Empty[XFileInfo]()
        if ($this.GetIsDirectory())
        {
            $add=[System.IO.Directory]::GetFiles($this._path)  
            if ($null -eq $add)
            {
                $add=[System.Linq.Enumerable]::Empty[XFileInfo]()
            }
            elseif ($add -is [string])
            {
                $add=[System.Linq.Enumerable]::Repeat[string]($add,1)
            }   
                 
            $add=[System.Linq.Enumerable]::Select[string,XFileInfo]($add,[XFileInfo]::ConvertPathToXFileInfoBlockFunc())
            
            
            $output=[System.Linq.Enumerable]::Concat[XFileInfo]($output,$add)
            
            $add=[System.IO.Directory]::GetDirectories($this._path)
            if ($null -eq $add)
            {
                $add=[System.Linq.Enumerable]::Empty[XFileInfo]()
            }
            elseif ($add -is [string])
            {
                $add=[System.Linq.Enumerable]::Repeat[string]($add,1)
            }  
            $add=[System.Linq.Enumerable]::Select[string,XFileInfo]($add,[XFileInfo]::ConvertPathToXFileInfoBlockFunc())
            
            $output=[System.Linq.Enumerable]::Concat[XFileInfo]($output,$add)
            $output=[System.Linq.Enumerable]::OrderBy($output,[XFileInfo]::XFileInfoKeyFieldSelectorScriptBlockFunc())            
        }
        return $output
    }
    [datetime] GetCreationTime()
    {
        return [System.IO.File]::GetCreationTimeUtc($this._path)
    }
    [datetime] GetLastModifiedTime()
    {
        return [System.IO.File]::GetLastWriteTimeUtc($this._path)
    }

    hidden static [XFileInfo] ConvertPathToXFileInfo([string]$path)
    {
        
        return [XFileInfo]::new($path)
    }
    hidden static [scriptblock] ConvertPathToXFileInfoBlock()
    {        
        return {
            param ([string]$path)
            return [XFileInfo]::ConvertPathToXFileInfo($path)
        }
    }
    hidden static [Func[string,XFileInfo]] ConvertPathToXFileInfoBlockFunc()
    {
        
        return [Func[string,XFileInfo]][XFileInfo]::ConvertPathToXFileInfoBlock()
    }
    hidden static [string] XFileInfoKeyFieldSelector([XFileInfo]$xFileInfo)
    {
        return $xFileInfo.GetPath()
    }
    hidden static [scriptblock] XFileInfoKeyFieldSelectorScriptBlock()
    {
        return {
            param ([XFileInfo]$xFileInfo)
            return [XFileInfo]::XFileInfoKeyFieldSelector($xFileInfo)
        }
    }
    hidden static [Func[XFileInfo,string]] XFileInfoKeyFieldSelectorScriptBlockFunc()
    {
        return [Func[XFileInfo,string]][XFileInfo]::XFileInfoKeyFieldSelectorScriptBlock()
    }
    
    hidden [int] GetSubItemCount()
    {
        $subitems = $this.GetSubitems()
        $count = [System.Linq.Enumerable]::Count[XFileInfo]($subitems)
        return $count
    }
    hidden [System.Action] EmptySetterCall()
    {
        $block = {
            ([object]$args)
            $this.EmptySetter($args)
        }
        return [Func[void]]($block)
    }
    hidden [void] EmptySetter([object]$myargs)
    {

    }
    hidden [void] AddProperty([string]$name,[scriptblock]$code)
    {
        $this._props.Add($($this | Add-Member ScriptProperty $name $code {
            param ($xargs)
            $this.EmptySetter($xargs)
        }))
    }
    hidden [void] InitializeCalculatedProperties()
    {
        $this._props=[System.Collections.ArrayList]::new()
        $this.AddProperty('Path',{
            return $this.GetPath()
        })
        $this.AddProperty('Name',{
            return $this.GetName()
        })
        $this.AddProperty('IsDirectory',{
            return $this.GetIsDirectory()
        })
        $this.AddProperty('Length',{
            return $this.GetLength()
        })
        $this.AddProperty('CreationTime',{
            return $this.GetCreationTime()
        })
        $this.AddProperty('LastModifiedTime', {
            return $this.GetLastModifiedTime()
        })
    }
    XFileInfo([string]$path)
    {
        $this.InitializePath($path)
        $this.InitializeCalculatedProperties()
    }

}