window.updateTime = function(str) {
    document.getElementById('result').innerText = str
}

let prevTaskReturned = true
window.setInterval(async () => {
    if(!prevTaskReturned) return;
    prevTaskReturned = false;
    const result = await window.CSUtil.GetTime()
    await DotNet.invokeMethod('blazor', 'Tick');
    const counter = await DotNet.invokeMethod('blazor', 'GetCounter')
    prevTaskReturned = true;
    window.updateTime(counter)
}, 1000/60)