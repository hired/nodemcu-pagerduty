apiHost     = "https://api.pagerduty.com"
apiEndpoint = "/incidents?statuses%5B%5D=triggered&statuses%5B%5D=acknowledged&urgencies%5B%5D=high"
led_pin     = 4
buzzer_pin  = 1
strobe_pin  = 2

globalHeaders = "Authorization: Token token=" .. api_key .. "\r\n"
globalHeaders = globalHeaders .. "Accept: application/vnd.pagerduty+json;version=2\r\n"
