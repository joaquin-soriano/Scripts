$tpm = Get-Tpm
$testConn = Test-Connection SRVDC1DC1
$bde = Get-BitLockerVolume | Select-Object *

if($testConn){

    foreach ($disco in $bde)
    {
        if($disco.ProtectionStatus -eq "Off")
        {
            if($disco.KeyProtector.KeyProtectorType -notcontains 'RecoveryPassword')
            {
                manage-bde -protectors -add $disco.MountPoint -recoverypassword
            }
            
            if($disco.VolumeType -eq 'OperatingSystem')
            {
                if($tpm.TpmPresent -eq 'True')
                {
                    if($disco.KeyProtector.KeyProtectorType -notcontains 'Tpm')
                    {
                        Add-BitLockerKeyProtector -MountPoint $disco.MountPoint -TpmProtector
                    }
                }
            }

            if($disco.VolumeType -eq 'Data')
            {
                $pathRK = $env:HOMEDRIVE + "\ScriptBitLocker"
                manage-bde -protectors -add $disco.MountPoint -rk $pathRK
            }

            $volumenAct = Get-BitLockerVolume -MountPoint $disco.MountPoint | Select-Object *
            $indice = 0
            $protectores = $volumenAct.KeyProtector
            while($protectores[$indice].KeyProtectorType -cnotlike "RecoveryPassword")
            {
                $indice += 1
                
            }
            
            $idProtectorRecoveryPwd = $protectores[$indice].KeyProtectorId
            

            while(-not $testConn)
            {
                Start-Sleep -Seconds 10
                $testConn = Test-Connection SRVDC1DC1
            }

            if($testConn)
            {
                manage-bde -protectors -adbackup $disco.MountPoint -id $idProtectorRecoveryPwd
                manage-bde -on $disco.MountPoint
            }

            

        
            
        }
    }
}
