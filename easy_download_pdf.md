# Easy step by step guide to download view only PDF from Google Drive - no TrustedScriptURL error and better quality
_________
1. Open the document in Google Docs
2. Zoom in 2 times using Ctrl and + (VERY IMPORTANT!)
3. Open Developer Tools
4. Hit Ctrl + R to reload the document.
5. Scroll to the bottom of the document to load all pages.
6. To check if all pages are loaded, go to "Network" tab, type "img" in search bar. At the bottom bar you see "xx/yyy requests", "xx" must be equal to document's pages; if not scroll up to load missing pages
7. Go to "Console" tab
8. Paste the updated and improved script (download_pdf.js) that avoids TrustedScriptURL error and allows better file's quality
___
If you want to download the file at lower resolution or you have issues with zoom method, use lowres_download.js script.
