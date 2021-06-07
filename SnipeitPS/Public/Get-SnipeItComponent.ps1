<#
.SYNOPSIS
Gets a list of Snipe-it Components

.PARAMETER search
A text string to search the Components data

.PARAMETER id
A id of specific Component

.PARAMETER limit
Specify the number of results you wish to return. Defaults to 50. Defines batch size for -all

.PARAMETER offset
Offset to use

.PARAMETER all
A return all results, works with -offset and other parameters

.PARAMETER url
URL of Snipeit system,can be set using Set-SnipeItInfo command

.PARAMETER apiKey
Users API Key for Snipeit, can be set using Set-SnipeItInfo command

.EXAMPLE
Get-SnipeItComponent
Returns all components

.EXAMPLE
Get-SnipeItComponent -search display
Returns search results containeing string display

.EXAMPLE
Get-SnipeItComponent -id
Returns specific component

#>

function Get-SnipeItComponent() {
    Param(
        [parameter(ParameterSetName='Search')]
        [string]$search,

        [parameter(ParameterSetName='Get with ID')]
        [int]$id,

        [parameter(ParameterSetName='Search')]
        [int]$category_id,

        [parameter(ParameterSetName='Search')]
        [int]$company_id,

        [parameter(ParameterSetName='Search')]
        [int]$location_id,

        [parameter(ParameterSetName='Search')]
        [ValidateSet("asc", "desc")]
        [string]$order = "desc",

        [parameter(ParameterSetName='Search')]
        [ValidateSet('id', 'name', 'min_amt', 'order_number', 'serial', 'purchase_date', 'purchase_cost', 'company', 'category', 'qty', 'location', 'image', 'created_at')]
        [string]$sort = "created_at",

        [parameter(ParameterSetName='Search')]
        [int]$limit = 50,

        [parameter(ParameterSetName='Search')]
        [int]$offset,

        [parameter(ParameterSetName='Search')]
        [switch]$all = $false,

        [parameter(mandatory = $true)]
        [string]$url,

        [parameter(mandatory = $true)]
        [string]$apiKey
    )

    Test-SnipeItAlias -invocationName $MyInvocation.InvocationName -commandName $MyInvocation.MyCommand.Name

    $SearchParameter = . Get-ParameterValue $MyInvocation.MyCommand.Parameters

    $apiurl = "$url/api/v1/components"

    if ($search -and $id ) {
         Throw "[$($MyInvocation.MyCommand.Name)] Please specify only -search or -id parameter , not both "
    }

    if ($id) {
       $apiurl= "$url/api/v1/components/$id"
    }

    $Parameters = @{
        Uri           = $apiurl
        Method        = 'Get'
        Token         = $apiKey
        GetParameters = $SearchParameter
    }

    if ($all) {
        $offstart = $(if($offset){$offset} Else {0})
        $callargs = $SearchParameter
        $callargs.Remove('all')

        while ($true) {
            $callargs['offset'] = $offstart
            $callargs['limit'] = $limit
            $res=Get-SnipeItComponent @callargs
            $res
            if ($res.count -lt $limit) {
                break
            }
            $offstart = $offstart + $limit
        }
    } else {
        $result = Invoke-SnipeitMethod @Parameters
        $result
    }
}
