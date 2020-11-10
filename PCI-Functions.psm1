<#
 .SYNOPSIS
  Checks whether a given number was generated using the algorithm.

 .PARAMETER Number
  The number you want to validate.

 .EXAMPLE
  Test-ValidateCard "79927398712"
#>

#These are the valid match patterns.
#$SSN_Regex = "^(?!000)([0-6]\d{2}|7([0-6]\d|7[012]))([ -]?)(?!00)\d\d\3(?!0000)\d{4}$"
#$Visa_Regex = "4[0-9]{12}(?:[0-9]{3})?"
#$MasterCard_Regex = "5[1-5][0-9]{14}"
#$Amex_Regex = "3[47][0-9]{13}"
#$Discover_Regex = "6(?:011|5[0-9]{2})[0-9]{11}"
#Medicare_Regex = "/^([2-6]\d{7})(\d)/"

function Test-ValidateAll
{
    param
	(
        [Parameter(Mandatory=$True)]
        [string]$Number
    )
    if(Test-ValidateCard -Number $Number){return 'CreditCard'}
    if(Test-ValidateTFN -Number $Number){return 'TFN'}
    if(Test-ValidateABN -Number $Number){return 'ABN'}
    if(Test-ValidateACN -Number $Number){return 'ACN'}
    if(Test-ValidateMedicare -Number $Number){return 'Medicare'}
}
function Test-ValidateCard
{
    param
	(
        [Parameter(Mandatory=$True)]
        [string]$Number
    )
    # strip anything other than digits
    $Number = $Number -creplace '[^0-9]+', ''
    
    # check length is 16 digits
    if($Number.Length -eq 16)
    {
        $temp = $Number.ToCharArray()
        $Numbers = @(0) * $Number.Length
        [int]$sum=0
        [bool]$alt = $false

        for($i = $temp.Length -1; $i -ge 0; $i--) {
            $Numbers[$i] = [int]::Parse($temp[$i])
            if($alt){
                $Numbers[$i] *= 2
                if($Numbers[$i] -gt 9) {
                    $Numbers[$i] -= 9
                }
            }
            $sum += $Numbers[$i]
            $alt = !$alt
        }
        return ($sum % 10) -eq 0
    } else {
        return $false
    }
}

function Test-ValidateTFN
{
    param
	(
        [Parameter(Mandatory=$True)]
        [string]$Number
    )
    #Create Weight array
    $weights = @(1, 4, 3, 7, 5, 8, 6, 9, 10);
 
    # strip anything other than digits
    $Number = $Number -creplace '[^0-9]+',''
 
    # check length is 9 digits
    if ($Number.Length -eq 9) {
        #Convert string array to int array
        [array]$Digits = foreach ($Digit in $Number.ToCharArray()) {[int]::Parse($Digit)}
        # apply ato check method 
        [int]$sum = 0
        for($i = $weights.Length -1; $i -ge 0; $i--) {
            $sum += $Digits[$i] * $weights[$i]
        }
        return ($sum % 11) -eq 0
    } 
    return $false
}

function Test-ValidateABN
{
    param
	(
        [Parameter(Mandatory=$True)]
        [string]$Number
    )
    #Create Weight array
    $weights = @(10, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19)
 
    # strip anything other than digits
    $Number = $Number -creplace '[^0-9]+',''
 
    # check length is 11 digits
    if ($Number.Length -eq 11) {
        
        #Convert String arrary to int array
        [array]$Digits = foreach ($Digit in $Number.ToCharArray()) {[int]::Parse($Digit)}
        #Subtract 1 from the first (left) digit
        $Digits[0] = $Digits[0] -1
        
        # apply ato check method 
        [int]$sum = 0
        for($i = $weights.Length -1; $i -ge 0; $i--) {
            $sum += $Digits[$i] * $weights[$i]
        }
        return ($sum % 89) -eq 0
    } 
    return $false
}

function Test-ValidateACN
{
    param
	(
        [Parameter(Mandatory=$True)]
        [string]$Number
    )
    #Create Weight array
    $weights = @(8,7,6,5,4,3,2,1);
 
    # strip anything other than digits
    $Number = $Number -creplace '[^0-9]+',''
 
    # check length is 9 digits
    if ($Number.Length -eq 9) {
        #Convert String arrary to int array
        [array]$Digits = foreach ($Digit in $Number.ToCharArray()) {[int]::Parse($Digit)}
        
        # apply ato check method 
        [int]$sum = 0
        for($i = $weights.Length -1; $i -ge 0; $i--) {
            $sum += $Digits[$i] * $weights[$i]
        }
        $check = (10 - ($sum % 10)) % 10;
        return $Digits[8] -eq $check;
    } 
    return $false
}

function Test-ValidateMedicare
{
    param
	(
        [Parameter(Mandatory=$True)]
        [string]$Number
    )
    #Create Weight array
    $weights = @(1,3,7,9,1,3,7,9)

    # strip anything other than digits
    $Number = $Number -creplace '[^0-9]+',''

    # Check for 11 digits
    if ($Number.Length -ge 10) {
        if($Number -match "^([2-6]\d{7})(\d)" ){
            #Convert String arrary to int array

            [array]$base = [int[]](($Matches[1] -split '') -ne '')
            [int]$checkDigit = $matches[2]
            [int]$sum = 0
            for($i = $weights.Length -1; $i -ge 0; $i--) {
                $sum += $base[$i] * $weights[$i]
            }
        }
        return ($sum % 10) -eq $checkDigit
    }
    return $false
}