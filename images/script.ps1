# Script API Proxmox
# Joshua Keely & Yanis Legentil - B2G1 
#============== Functions ==============#

function prerequisites {
    cls
    Write-Host -ForegroundColor Green " Would you like to install the pre-requisites (Recommended on first start-up) ? 
    
    "
    $c = Read-Host ' install pre-requisistes (y/n) '
    if ($c -eq 'y') {
        Write-Progress -Activity "Installing pre-requisites" -Status "Installing NodeJS..." -PercentComplete 20
        winget install OpenJS.NodeJS --silent
        cls
        Write-Progress -Activity "Installing pre-requisites" -Status "Installing Figlet..." -PercentComplete 30
        npm install -g figlet-cli --silent
        Write-Progress -Activity "Installing pre-requisites" -Status "Installing Corsinvest..." -PercentComplete 50
        Install-Module -Name Corsinvest.ProxmoxVE.Api -RequiredVersion 7.1.4
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Write-Progress -Activity "Installing pre-requisites" -Status "Installing Corsinvest..." -PercentComplete 70
        Install-Module -Name Corsinvest.ProxmoxVE.Api -RequiredVersion 7.1.4
        Write-Progress -Activity "Installing pre-requisites" -Status "Building documentation..." -PercentComplete 90
        Build-PVEdocumentation
        Write-Progress -Activity "Installing pre-requisites" -Status "Done" -Completed
        Start-Sleep -Seconds 2
        cls
    }
    else {
        cls
    }

}
function menu {
    figlet SAE Proxmox
    Write-Host "
    ==========================================================
    Welcome to the Proxmox script, what would you like to do ? 

    1) Connect to Proxmox server
    2) Create new clone
    3) Mass cloning
    4) Other
    5) Exit
    
    "
    $c0 = Read-Host ' Your choice '
    if ($c0 -eq 1) {
        cls
        pveConnect
        cls
        menu
    }
    if ($c0 -eq 2) {
        cls
        pveClone
        cls 
        menu
    }
    if ($c0 -eq 3) {
        cls
        pveMassClone
        cls
        menu
    }
    if ($c0 -eq 4) {
        cls
        pveOtherFunctions
        cls
        menu
    }
    if ($c0 -eq 5) {
        cls
        Write-Host -ForegroundColor Green "Goodbye !"
        Start-Sleep -Seconds 2
        cls
        Exit
    }
    
}

function pveConnect {
    figlet SAE Proxmox
    Write-Host "
    ===========================
    1) pve2-1  --> 10.1.2.75
    2) pve2-2  --> 10.1.2.175
    3) test --> 192.168.1.24
    4) Other
    
    "
    $c1 = Read-Host ' Host'
    $c2 = Read-Host ' Username'
    if (1 -eq $c1) {
        Connect-PveCluster -HostsAndPorts 10.1.2.75:8006 -Credentials (Get-Credential -Username "$c2") -SkipCertificateCheck
    }
    if (2 -eq $c1) {
        Connect-PveCluster -HostsAndPorts 10.1.2.175:8006 -Credentials (Get-Credential -Username "$c2") -SkipCertificateCheck 
    }
    if (3 -eq $c1) {
        Connect-PveCluster -HostsAndPorts 192.168.1.24:8006 -Credentials (Get-Credential -Username "$c2") -SkipCertificateCheck 
    }
    if (4 -eq $c1) {
        $c3 = Read-Host ' Host (e.g 10.1.2.75:8006) '
        Connect-PveCluster -HostsAndPorts $c3 -Credentials (Get-Credential -Username "$c2") -SkipCertificateCheck 

    }
    cls
    Write-Host -ForegroundColor Green " Connected to Proxmox Server !"
    Start-Sleep -Seconds 2
    
}

function pveClone {
    figlet SAE Proxmox
    Write-Host "
    ===========================
    Choose Operating System : 
    
    1) Linux - CentOs 8
    2) Windows 10
    3) Windows Server 2016
    4) Custom
    
    "
    $c4 = Read-Host ' Operating System '
    if (1 -eq $c4) {
        cls
        Write-Host -ForegroundColor Green " Operating System : Linux - CentOs 8"
        $c5 = Read-Host ' New VM name '
        $c6 = Read-Host ' Choose VMID for clonned VM (e.g 106) '
        New-PveNodesQemuClone -Name $c5 -Node pve2-1 -full -Storage local-zfs -Vmid 112 -Newid $c6
        Do {
            Write-Host 'Cloning...'
            Start-Sleep -Seconds 1
            cls
        } while ((Get-PveNodesQemuStatusCurrent -Vmid $c6 -Node pve2-1).Response.data.lock -eq "clone")
        $c7 = Read-Host ' Password for VM '$c6' '
        New-PveNodesQemuConfig -Vmid $c6 -Node pve2-1 -Cipassword (ConvertTo-SecureString "$c7" -AsPlainText -Force)
        $c8 = Read-Host ' IP for VM '$c6' '
        $c9 = Read-Host ' Mask for VM '$c6' (8-16-24)'
        $c10 = Read-Host ' Gateway for VM '$c6' '
        $Iplist = @{}
        $Iplist[0] = "ip=$c8/$c9,gw=$c10"
        Set-PveNodesQemuConfig -Node pve2-1 -Vmid $c6 -ipconfigN $Iplist
        Set-PveNodesQemuConfig -Node pve2-1 -Vmid $c6 -Nameserver 8.8.8.8
        #Set-PveNodesQemuConfig -Node pve2-1 -Vmid $c6 -Sshkeys "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAm+cfgzLX2T40RrL6DOvX7Nh/i6YY6Fdma1ztz4lJyZGXT9HwlMSqTuSQBI2+DvaF7vP/ImEBxRLH6h6PPuaCAvBC5JZowxWJS1cxrSKTNXdyHUVHMDun28deDVViwlJHV+OueYwsVM8kFhM932EsjGrTiAY8BCVZrBYTHa6OP8DprhAGYDGXWDFq2GxOvWB5nPrzoqx0DN63occQ8Vx2AkFrH3ik7zRAyU0+P4qDzFdYdevKdbSZOzfdqnGlbLAHDCScGWHMrqAaLZWUU65F+i8HFBwG7YBerPBKmvRBfc8jpQN8Xd++8dH7Vl7J1nCVi5Q5tTyScgllKJACHQs+Vw== rsa-key-20221201"
        New-PveNodesQemuStatusStart -Node pve2-1 -Vmid $c6
        Do {
            Write-Host 'Starting...'
            Start-Sleep -Seconds 1
            cls
        } while ((Get-PveNodesQemuStatusCurrent -Vmid $c6 -Node pve2-1).Response.data.status -eq "Stopped")
        cls
        Write-Host "
        VMID : $c6
        IP Address : $c8/$c9
        Gateway : $c10
        Password : Toto1234 (Function does not work)"
        Start-Sleep -Seconds 4
        cls
        Write-Host -ForegroundColor Green " VM Configuration done !"
        Start-Sleep -Seconds 2
        cls
        menu
    }
    if (2 -eq $c4) {
        cls
        Write-Host -ForegroundColor Green " Operating System : Windows 10"
        $c5 = Read-Host ' New VM name '
        $c6 = Read-Host ' Choose VMID for clonned VM (e.g 106) '
        New-PveNodesQemuClone -Name $c5 -Node pve2-1 -full -Storage local-zfs -Vmid 112 -Newid $c6
        Do {
            Write-Host 'Cloning...'
            Start-Sleep -Seconds 1
            cls
        } while ((Get-PveNodesQemuStatusCurrent -Vmid $c6 -Node pve2-1).Response.data.lock -eq "clone")
        $c7 = Read-Host ' Password for VM '$c5' '
        New-PveNodesQemuConfig -Vmid $c6 -Node pve2-1 -Cipassword (ConvertTo-SecureString "$c7" -AsPlainText -Force)
        $c8 = Read-Host ' IP for VM '$c6' '
        $c9 = Read-Host ' Mask for VM '$c6' (8-16-24)'
        $c10 = Read-Host ' Gateway for VM '$c6' '
        $Iplist = @{}
        $Iplist[0] = "ip=$c8/$c9,gw=$c10"
        Set-PveNodesQemuConfig -Node pve2-1 -Vmid $c6 -ipconfigN $Iplist
        Set-PveNodesQemuConfig -Node pve2-1 -Vmid $c6 -Nameserver 8.8.8.8
        #Set-PveNodesQemuConfig -Node pve2-1 -Vmid $c6 -Sshkeys "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAm+cfgzLX2T40RrL6DOvX7Nh/i6YY6Fdma1ztz4lJyZGXT9HwlMSqTuSQBI2+DvaF7vP/ImEBxRLH6h6PPuaCAvBC5JZowxWJS1cxrSKTNXdyHUVHMDun28deDVViwlJHV+OueYwsVM8kFhM932EsjGrTiAY8BCVZrBYTHa6OP8DprhAGYDGXWDFq2GxOvWB5nPrzoqx0DN63occQ8Vx2AkFrH3ik7zRAyU0+P4qDzFdYdevKdbSZOzfdqnGlbLAHDCScGWHMrqAaLZWUU65F+i8HFBwG7YBerPBKmvRBfc8jpQN8Xd++8dH7Vl7J1nCVi5Q5tTyScgllKJACHQs+Vw== rsa-key-20221201"
        New-PveNodesQemuStatusStart -Node pve2-1 -Vmid $c6
        Do {
            Write-Host 'Starting...'
            Start-Sleep -Seconds 1
            cls
        } while ((Get-PveNodesQemuStatusCurrent -Vmid $c6 -Node pve2-1).Response.data.status -eq "Stopped")
        cls
        Write-Host "
        VMID : $c6
        IP Address : $c8/$c9
        Gateway : $c10
        Password : Toto1234 (Function does not work)"
        Start-Sleep -Seconds 4
        cls
        Write-Host -ForegroundColor Green " VM Configuration done !"
        Start-Sleep -Seconds 2
        cls
        menu
    }
    if (3 -eq $c4) {
        cls
        Write-Host -ForegroundColor Green " Operating System : Windows Server 2016 "
        $c5 = Read-Host ' New VM name '
        $c6 = Read-Host ' Choose VMID for clonned VM (e.g 106) '
        New-PveNodesQemuClone -Name $c5 -Node pve2-2 -full -Storage local-zfs -Vmid 101 -Newid $c6
        Do {
            Write-Host 'Cloning...'
            Start-Sleep -Seconds 1
            cls
        } while ((Get-PveNodesQemuStatusCurrent -Vmid $c6 -Node pve2-1).Response.data.lock -eq "clone")
        $c7 = Read-Host ' Password for VM '$c6' '
        New-PveNodesQemuConfig -Vmid $c6 -Node pve2-2 -Cipassword (ConvertTo-SecureString "$c7" -AsPlainText -Force)
        $c8 = Read-Host ' IP for VM '$c6' '
        $c9 = Read-Host ' Mask for VM '$c6' (8-16-24)'
        $c10 = Read-Host ' Gateway for VM '$c6' '
        $Iplist = @{}
        $Iplist[0] = "ip=$c8/$c9,gw=$c10"
        Set-PveNodesQemuConfig -Node pve2-2 -Vmid $c6 -ipconfigN $Iplist
        Set-PveNodesQemuConfig -Node pve2-2 -Vmid $c6 -Nameserver 8.8.8.8
        #Set-PveNodesQemuConfig -Node pve2-1 -Vmid $c6 -Sshkeys "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAm+cfgzLX2T40RrL6DOvX7Nh/i6YY6Fdma1ztz4lJyZGXT9HwlMSqTuSQBI2+DvaF7vP/ImEBxRLH6h6PPuaCAvBC5JZowxWJS1cxrSKTNXdyHUVHMDun28deDVViwlJHV+OueYwsVM8kFhM932EsjGrTiAY8BCVZrBYTHa6OP8DprhAGYDGXWDFq2GxOvWB5nPrzoqx0DN63occQ8Vx2AkFrH3ik7zRAyU0+P4qDzFdYdevKdbSZOzfdqnGlbLAHDCScGWHMrqAaLZWUU65F+i8HFBwG7YBerPBKmvRBfc8jpQN8Xd++8dH7Vl7J1nCVi5Q5tTyScgllKJACHQs+Vw== rsa-key-20221201"
        New-PveNodesQemuStatusStart -Node pve2-2 -Vmid $c6
        Do {
            Write-Host 'Starting...'
            Start-Sleep -Seconds 1
            cls
        } while ((Get-PveNodesQemuStatusCurrent -Vmid $c6 -Node pve2-2).Response.data.status -eq "Stopped")
        cls
        Write-Host "
         VMID : $c6
         IP Address : $c8/$c9
         Gateway : $c10
         Password : Toto1234 (Function does not work)"
        Start-Sleep -Seconds 4
        cls
        Write-Host -ForegroundColor Green " VM Configuration done !"
        Start-Sleep -Seconds 2
        cls
        menu
    }
    if (4 -eq $c4) {
        cls
        Write-Host -ForegroundColor Green " Operating System : Custom OS "
        $c5 = Read-Host ' New VM name '
        $c6 = Read-Host ' Choose node (e.g pve2-1) '
        $c7 = Read-Host ' Choose VMID for desired template (e.g 106) '
        $c8 = Read-Host ' Choose VMID for clonned VM (e.g 106) '
        $c81 = Read-Host ' Storage (e.g local-zfs) '
        New-PveNodesQemuClone -Name $c5 -Node $c6 -full -Storage $c81 -Vmid $c7 -Newid $c8
        Do {
            Write-Host 'Cloning...'
            Start-Sleep -Seconds 1
            cls
        } while ((Get-PveNodesQemuStatusCurrent -Vmid $c8 -Node $c6).Response.data.lock -eq "clone")
        $c7 = Read-Host ' Password for VM '$c12' '
        New-PveNodesQemuConfig -Vmid $c8 -Node $c6 -Cipassword (ConvertTo-SecureString "$c12" -AsPlainText -Force)
        $c9 = Read-Host ' IP for VM '$c8' '
        $c10 = Read-Host ' Mask for VM '$c8' (8-16-24)'
        $c11 = Read-Host ' Gateway for VM '$c8' '
        $Iplist = @{}
        $Iplist[0] = "ip=$c9/$c10,gw=$c11"
        Set-PveNodesQemuConfig -Node $c6 -Vmid $c8 -ipconfigN $Iplist
        Set-PveNodesQemuConfig -Node $c6 -Vmid $c8 -Nameserver 8.8.8.8
        #Set-PveNodesQemuConfig -Node pve2-1 -Vmid $c6 -Sshkeys "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAm+cfgzLX2T40RrL6DOvX7Nh/i6YY6Fdma1ztz4lJyZGXT9HwlMSqTuSQBI2+DvaF7vP/ImEBxRLH6h6PPuaCAvBC5JZowxWJS1cxrSKTNXdyHUVHMDun28deDVViwlJHV+OueYwsVM8kFhM932EsjGrTiAY8BCVZrBYTHa6OP8DprhAGYDGXWDFq2GxOvWB5nPrzoqx0DN63occQ8Vx2AkFrH3ik7zRAyU0+P4qDzFdYdevKdbSZOzfdqnGlbLAHDCScGWHMrqAaLZWUU65F+i8HFBwG7YBerPBKmvRBfc8jpQN8Xd++8dH7Vl7J1nCVi5Q5tTyScgllKJACHQs+Vw== rsa-key-20221201"
        New-PveNodesQemuStatusStart -Node $c6 -Vmid $c8
        Do {
            Write-Host 'Starting...'
            Start-Sleep -Seconds 1
            cls
        } while ((Get-PveNodesQemuStatusCurrent -Vmid $c8 -Node $c6).Response.data.status -eq "Stopped")
        cls
        Write-Host "
        VMID : $c8
        IP Address : $c9/$c10
        Gateway : $c11
        Password : Toto1234 (Function does not work)"
        Start-Sleep -Seconds 4
       cls
        Write-Host -ForegroundColor Green " VM Configuration done !"
        Start-Sleep -Seconds 2
        cls
        menu
    }
}

function pvePassword {
  figlet SAE Proxmox
  Write-Host "
    ==========================================
    Which password would you like to change ?  

    "
    
}
function pveOtherFunctions {
    figlet SAE Proxmox
    Write-Host "
    ====================
    Optional features: 

    1) Change password on VM
    2) Check VM status

    "
    $c13 = Read-Host 'Your choice '
    if ($c13 -eq 1) {
        <# Action to perform if the condition is true #>
    }
    if ($c13 -eq 2) {
        <# Action to perform if the condition is true #>
    }
    
}

function pveMassClone {
    figlet SAE Proxmox
    $c14 = Read-Host ' Path to CSV file '
    $CSV = Import-Csv -Path "$c14" -Delimiter ","
    
    $CSV | ForEach-Object{
        New-PveNodesQemuClone -Name $($_.Nom) -Node pve2-1 -Vmid 112 -Newid $($_.vmid)
        Do {
            Write-Host 'Cloning...'
            Start-Sleep -Seconds 1
            cls
        } while ((Get-PveNodesQemuStatusCurrent -Vmid $($_.vmid) -Node pve2-1).Response.data.lock -eq "clone")
        New-PveNodesQemuConfig -Vmid $VMID -Node pve2-1 -Cipassword (ConvertTo-SecureString "$($_."mot de passe user")" -AsPlainText -Force)
        $Iplist = @{}
        $Iplist[0] = "ip=$($_.IP)/24,gw=10.98.10.254"
        Set-PveNodesQemuConfig -Node pve2-1 -Vmid $($_.vmid) -ipconfigN $Iplist
        Set-PveNodesQemuConfig -Node pve2-1 -Vmid $($_.vmid) -Nameserver 8.8.8.8
        

    }

    
    
    
}

#============== Main Program ==============#
prerequisites
menu

