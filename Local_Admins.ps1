$admins = Get-LocalGroupMember -Group "Administradores"
$GG_ADM_WKS = "GMIRGOR\GG-Admin WKS"
$ADM_LOCAL = $env:COMPUTERNAME + "\Administrador"
$DOM_ADM = "GMIRGOR\Domain Admins"
$sendermailaddress = "Seguridad_Informatica@mirgor.com.ar"            
$SMTPserver = "192.168.5.91"
$asuntoBASE = "Administradores locales de maquina "
$body = "Los siguientes usuarios son adminstradores locales de la maquina: " + "`r`n`r`n"
[int]$nroAdmins = 0

function SendMail ($SMTPserver,$sendermailaddress,$mailBody,$asuntoFinal)            
{            
    $smtpServer = $SMTPserver            
    $msg = new-object Net.Mail.MailMessage            
    $smtp = new-object Net.Mail.SmtpClient($smtpServer)            
    $msg.From = $sendermailaddress            
    $msg.To.Add("Secops@mirgor.com.ar")   
    $msg.Subject = $asuntoFinal           
    $msg.Body = $mailBody            
    $smtp.Send($msg)            
}


foreach($administrador in $admins)
{
    if($administrador.Name -ne $GG_ADM_WKS -and $administrador.Name -ne $ADM_LOCAL -and $administrador.Name -ne $DOM_ADM)
    {
        $nroAdmins += 1
        $body += $administrador.Name + "`r`n`r`n"
    }
}

$body += "****FIN****"

$asuntoOK = $asuntoBASE + $env:COMPUTERNAME

try
{

    if($nroAdmins -gt 0)
    {
        SendMail $SMTPserver $sendermailaddress $body $asuntoOK
        
    }
} catch
{
    Write-Output $body
}
