$path = $MyInvocation.MyCommand.Path
$src = (Split-Path -Parent -Path $path) -ireplace '[\\/]tests[\\/]unit', '/src/'
Get-ChildItem "$($src)/*.ps1" -Recurse | Resolve-Path | ForEach-Object { . $_ }

Describe 'Find-PodeSchedule' {
    Context 'Invalid parameters supplied' {
        It 'Throw null name parameter error' {
            { Find-PodeSchedule -Name $null } | Should Throw 'The argument is null or empty'
        }

        It 'Throw empty name parameter error' {
            { Find-PodeSchedule -Name ([string]::Empty) } | Should Throw 'The argument is null or empty'
        }
    }

    Context 'Valid values supplied' {
        It 'Returns null as the schedule does not exist' {
            $PodeContext = @{ 'Schedules' = @{}; }
            Find-PodeSchedule -Name 'test' | Should Be $null
        }

        It 'Returns schedule for name' {
            $PodeContext = @{ 'Schedules' = @{ 'test' = @{ 'Name' = 'test'; }; }; }
            $result = (Find-PodeSchedule -Name 'test')

            $result | Should BeOfType System.Collections.Hashtable
            $result.Name | Should Be 'test'
        }
    }
}

Describe 'Add-PodeSchedule' {
    Mock 'ConvertFrom-PodeCronExpression' { @{} }

    It 'Throws error because schedule already exists' {
        $PodeContext = @{ 'Schedules' = @{ 'test' = $null }; }
        { Add-PodeSchedule -Name 'test' -Cron '@hourly' -ScriptBlock {} } | Should Throw 'already defined'
    }

    It 'Throws error because end time in the past' {
        $PodeContext = @{ 'Schedules' = @{}; }
        $end = ([DateTime]::Now.AddHours(-1))
        { Add-PodeSchedule -Name 'test' -Cron '@hourly' -ScriptBlock {} -EndTime $end } | Should Throw 'the EndTime value must be in the future'
    }

    It 'Throws error because start time is after end time' {
        $PodeContext = @{ 'Schedules' = @{}; }
        $start = ([DateTime]::Now.AddHours(3))
        $end = ([DateTime]::Now.AddHours(1))
        { Add-PodeSchedule -Name 'test' -Cron '@hourly' -ScriptBlock {} -StartTime $start -EndTime $end } | Should Throw 'starttime after the endtime'
    }

    It 'Adds new schedule supplying everything' {
        $PodeContext = @{ 'Schedules' = @{}; }
        $start = ([DateTime]::Now.AddHours(3))
        $end = ([DateTime]::Now.AddHours(5))

        Add-PodeSchedule -Name 'test' -Cron '@hourly' -ScriptBlock { Write-Host 'hello' } -StartTime $start -EndTime $end

        $schedule = $PodeContext.Schedules['test']
        $schedule | Should Not Be $null
        $schedule.Name | Should Be 'test'
        $schedule.StartTime | Should Be $start
        $schedule.EndTime | Should Be $end
        $schedule.Script | Should Not Be $null
        $schedule.Script.ToString() | Should Be ({ Write-Host 'hello' }).ToString()
        $schedule.Crons.Length | Should Be 1
    }

    It 'Adds new schedule with no start time' {
        $PodeContext = @{ 'Schedules' = @{}; }
        $end = ([DateTime]::Now.AddHours(5))

        Add-PodeSchedule -Name 'test' -Cron '@hourly' -ScriptBlock { Write-Host 'hello' } -EndTime $end

        $schedule = $PodeContext.Schedules['test']
        $schedule | Should Not Be $null
        $schedule.Name | Should Be 'test'
        $schedule.StartTime | Should Be $null
        $schedule.EndTime | Should Be $end
        $schedule.Script | Should Not Be $null
        $schedule.Script.ToString() | Should Be ({ Write-Host 'hello' }).ToString()
        $schedule.Crons.Length | Should Be 1
    }

    It 'Adds new schedule with no end time' {
        $PodeContext = @{ 'Schedules' = @{}; }
        $start = ([DateTime]::Now.AddHours(3))

        Add-PodeSchedule -Name 'test' -Cron '@hourly' -ScriptBlock { Write-Host 'hello' } -StartTime $start

        $schedule = $PodeContext.Schedules['test']
        $schedule | Should Not Be $null
        $schedule.Name | Should Be 'test'
        $schedule.StartTime | Should Be $start
        $schedule.EndTime | Should Be $null
        $schedule.Script | Should Not Be $null
        $schedule.Script.ToString() | Should Be ({ Write-Host 'hello' }).ToString()
        $schedule.Crons.Length | Should Be 1
    }

    It 'Adds new schedule with just a cron' {
        $PodeContext = @{ 'Schedules' = @{}; }

        Add-PodeSchedule -Name 'test' -Cron '@hourly' -ScriptBlock { Write-Host 'hello' }

        $schedule = $PodeContext.Schedules['test']
        $schedule | Should Not Be $null
        $schedule.Name | Should Be 'test'
        $schedule.StartTime | Should Be $null
        $schedule.EndTime | Should Be $null
        $schedule.Script | Should Not Be $null
        $schedule.Script.ToString() | Should Be ({ Write-Host 'hello' }).ToString()
        $schedule.Crons.Length | Should Be 1
    }

    It 'Adds new schedule with two crons' {
        $PodeContext = @{ 'Schedules' = @{}; }
        $start = ([DateTime]::Now.AddHours(3))
        $end = ([DateTime]::Now.AddHours(5))

        Add-PodeSchedule -Name 'test' -Cron @('@minutely', '@hourly') -ScriptBlock { Write-Host 'hello' } -StartTime $start -EndTime $end

        $schedule = $PodeContext.Schedules['test']
        $schedule | Should Not Be $null
        $schedule.Name | Should Be 'test'
        $schedule.StartTime | Should Be $start
        $schedule.EndTime | Should Be $end
        $schedule.Script | Should Not Be $null
        $schedule.Script.ToString() | Should Be ({ Write-Host 'hello' }).ToString()
        $schedule.Crons.Length | Should Be 2
    }
}

Describe 'Get-PodeSchedule' {
    It 'Returns no schedules' {
        $PodeContext = @{ Schedules = @{} }
        $schedules = Get-PodeSchedule
        $schedules.Length | Should Be 0
    }

    It 'Returns 1 schedule by name' {
        $PodeContext = @{ Schedules = @{} }
        $start = ([DateTime]::Now.AddHours(3))
        $end = ([DateTime]::Now.AddHours(5))

        Add-PodeSchedule -Name 'test1' -Cron '@hourly' -ScriptBlock { Write-Host 'hello' } -StartTime $start -EndTime $end
        $schedules = Get-PodeSchedule
        $schedules.Length | Should Be 1

        $schedules.Name | Should Be 'test1'
        $schedules.StartTime | Should Be $start
        $schedules.EndTime | Should Be $end
        $schedules.Limit | Should Be 0
    }

    It 'Returns 2 schedules by name' {
        $PodeContext = @{ Schedules = @{} }
        $start = ([DateTime]::Now.AddHours(3))
        $end = ([DateTime]::Now.AddHours(5))

        Add-PodeSchedule -Name 'test1' -Cron '@hourly' -ScriptBlock { Write-Host 'hello' } -StartTime $start -EndTime $end
        Add-PodeSchedule -Name 'test2' -Cron '@hourly' -ScriptBlock { Write-Host 'hello' } -StartTime $start -EndTime $end
        Add-PodeSchedule -Name 'test3' -Cron '@hourly' -ScriptBlock { Write-Host 'hello' } -StartTime $start -EndTime $end

        $schedules = Get-PodeSchedule -Name test1, test2
        $schedules.Length | Should Be 2
    }

    It 'Returns all schedules' {
        $PodeContext = @{ Schedules = @{} }
        $start = ([DateTime]::Now.AddHours(3))
        $end = ([DateTime]::Now.AddHours(5))

        Add-PodeSchedule -Name 'test1' -Cron '@hourly' -ScriptBlock { Write-Host 'hello' } -StartTime $start -EndTime $end
        Add-PodeSchedule -Name 'test2' -Cron '@hourly' -ScriptBlock { Write-Host 'hello' } -StartTime $start -EndTime $end
        Add-PodeSchedule -Name 'test3' -Cron '@hourly' -ScriptBlock { Write-Host 'hello' } -StartTime $start -EndTime $end

        $schedules = Get-PodeSchedule
        $schedules.Length | Should Be 3
    }
}

Describe 'Remove-PodeSchedule' {
    It 'Adds new schedule and then removes it' {
        $PodeContext = @{ 'Schedules' = @{}; }

        Add-PodeSchedule -Name 'test' -Cron '@hourly' -ScriptBlock { Write-Host 'hello' }

        $PodeContext.Schedules['test'] | Should Not Be $null

        Remove-PodeSchedule -Name 'test'

        $PodeContext.Schedules['test'] | Should Be $null
    }
}


Describe 'Clear-PodeSchedules' {
    It 'Adds new schedules and then removes them' {
        $PodeContext = @{ 'Schedules' = @{}; }

        Add-PodeSchedule -Name 'test1' -Cron '@hourly' -ScriptBlock { Write-Host 'hello1' }
        Add-PodeSchedule -Name 'test2' -Cron '@hourly' -ScriptBlock { Write-Host 'hello2' }

        $PodeContext.Schedules['test1'] | Should Not Be $null
        $PodeContext.Schedules['test2'] | Should Not Be $null

        Clear-PodeSchedules

        $PodeContext.Schedules.Count | Should Be 0
    }
}

Describe 'Edit-PodeSchedule' {
    It 'Adds a new schedule, then edits the cron' {
        $PodeContext = @{ 'Schedules' = @{}; }
        Add-PodeSchedule -Name 'test1' -Cron '@hourly' -ScriptBlock { Write-Host 'hello1' }
        $PodeContext.Schedules['test1'].Crons.Length | Should Be 1
        $PodeContext.Schedules['test1'].Script.ToString() | Should Be ({ Write-Host 'hello1' }).ToString()

        Edit-PodeSchedule -Name 'test1' -Cron @('@minutely', '@hourly')
        $PodeContext.Schedules['test1'].Crons.Length | Should Be 2
        $PodeContext.Schedules['test1'].Script.ToString() | Should Be ({ Write-Host 'hello1' }).ToString()
    }

    It 'Adds a new schedule, then edits the script' {
        $PodeContext = @{ 'Schedules' = @{}; }
        Add-PodeSchedule -Name 'test1' -Cron '@hourly' -ScriptBlock { Write-Host 'hello1' }
        $PodeContext.Schedules['test1'].Crons.Length | Should Be 1
        $PodeContext.Schedules['test1'].Script.ToString() | Should Be ({ Write-Host 'hello1' }).ToString()

        Edit-PodeSchedule -Name 'test1' -ScriptBlock { Write-Host 'hello2' }
        $PodeContext.Schedules['test1'].Crons.Length | Should Be 1
        $PodeContext.Schedules['test1'].Script.ToString() | Should Be ({ Write-Host 'hello2' }).ToString()
    }
}