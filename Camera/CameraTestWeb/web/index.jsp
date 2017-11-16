<%--
  Created by IntelliJ IDEA.
  User: HZJ
  Date: 11/15/2017
  Time: 9:48 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Camera Test</title>
    <script>
        // example from https://davidwalsh.name/browser-camera
        function setUpCamera() {

            // Grab elements, create settings, etc.
            let video = document.getElementById('video');

            // Get access to the camera!
            if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
                // Not adding `{ audio: true }` since we only want video now
                navigator.mediaDevices.getUserMedia({video: true, audio: true}).then(function (stream) {
                    video.src = window.URL.createObjectURL(stream);
                    video.play();
                });
            }
        }

        function takePhoto() {
            // Elements for taking the snapshot
            let canvas = document.getElementById('canvas');
            let context = canvas.getContext('2d');
            let video = document.getElementById('video');

            // Trigger photo take
            document.getElementById("snap").addEventListener("click", function () {
                context.drawImage(video, 0, 0, 640, 480);
            });
        }
    </script>
</head>
<body onload="setUpCamera()">
<%--Ideally these elements aren't created until it's confirmed that the --%>
<%--client supports video/camera, but for the sake of illustrating the --%>
<%--elements involved, they are created with markup (not JavaScript)--%>
<video id="video" width="640" height="480" autoplay></video>
<button id="snap" onclick="takePhoto()">Snap Photo</button>
<canvas id="canvas" width="640" height="480"></canvas>
</body>
</html>
