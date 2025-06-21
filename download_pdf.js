// TrustedURL starting
let trustedURL;
if (window.trustedTypes && trustedTypes.createPolicy) {
    const policy = trustedTypes.createPolicy('myPolicy', {
        createScriptURL: (input) => {
            return input;
        }
    });
    trustedURL = policy.createScriptURL('https://cdnjs.cloudflare.com/ajax/libs/jspdf/1.5.3/jspdf.debug.js');
} else {
    trustedURL = 'https://cdnjs.cloudflare.com/ajax/libs/jspdf/1.5.3/jspdf.debug.js';
}
    
// Download script starting - EDITED AND IMPROVED BY cirippo
let jspdf = document.createElement("script");
 
jspdf.onload = function () {
 
    let pdf = new jsPDF('p', 'mm', [1200, 1200*1.414]);
    let elements = document.getElementsByTagName("img");
    for (let i in elements) {
        let img = elements[i];
        console.log("add img ", img);
        if (!/^blob:/.test(img.src)) {
            console.log("invalid src");
            continue;
        }
        let can = document.createElement('canvas');
        let con = can.getContext("2d");
        can.width = 1600;
        can.height = 2263;
        con.drawImage(img, 0, 0);
        let imgData = can.toDataURL("image/jpeg", 1.0);
        pdf.addImage(imgData, 'JPEG', 0, 0);
        pdf.addPage();
    }
 
    pdf.save("download.pdf");
};
 
jspdf.src = trustedURL;
document.body.appendChild(jspdf);
