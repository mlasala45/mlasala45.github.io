window.CSUtil = {
    GetTime: async function() {
        return await DotNet.invokeMethod('blazor', 'GetTimeStr');
    }
}