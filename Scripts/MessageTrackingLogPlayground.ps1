Get-MessageTrackingAllLogs -Sender dekanat@phil.uni-passau.de -Recipients m_alesi@yahoo.com -Start "2020-07-30" -End "2020-07-31"

Get-MessageTrackingAllLogs -Sender dekanat@ads.uni-passau.de -Start "2020-07-30" -End "2020-07-31"


Get-MessageTrackingAllLogs -Recipient maria.armansperger@yahoo.de -Start "2020-09-04" -OnlySendEvents


        Get-ExchangeServer | ForEach-Object {
            $exsrv=$_
            Get-MessageTrackingLog -Sender HAUSIN02@ads.uni-passau.de -Start "2020-09-04 09:20" -ResultSize Unlimited
        } | Sort-Object -Property Timestamp #| Select-Object -First 100
 