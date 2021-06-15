const container = document.querySelector("#curr-time");
setInterval(() => {
    container.textContent = (new Date()).toLocaleString();
}, 1000);