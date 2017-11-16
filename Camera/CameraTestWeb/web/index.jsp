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
        // tutorial: https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia
        let currentVideoDeviceIdx = 0;
        let videoDevices = [];
        let audioDevices = [];

        function init() {
            navigator.mediaDevices.enumerateDevices()
                .then(function (MediaDeviceInfo) {
                    MediaDeviceInfo.forEach((element) => {
                        if (element.kind.includes("videoinput")) {
//                            console.log(element);
                            videoDevices.push(element);
                        }
                        else if (element.kind.includes("audio")) {
//                            console.log(element);
                            audioDevices.push(element);
                        }
                    });

                    setUpCamera();
                });
        }

        function setUpCamera() {
            let video = document.getElementById('video');
            let constraints = {
                audio: true,
                video: videoDevices.length > 0
                    ? {
                        deviceId: videoDevices[currentVideoDeviceIdx].deviceId,
                        width: 1280,
                        height: 720
                    } : false,
            };

//            console.log(navigator.mediaDevices.getSupportedConstraints());

            // Get access to the camera!
            if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
                // Not adding `{ audio: true }` since we only want video now
                navigator.mediaDevices.getUserMedia(constraints).then(function (stream) {
//                    video.src = window.URL.createObjectURL(stream);
//                    video.play();

//                    let video = document.querySelector('video');
                    video.srcObject = stream;
                    video.onloadedmetadata = function (e) {
                        console.log(e);

                        video.play();
                    };
                }).catch(function (err) {
                    console.log(err.name + ": " + err.message);
                });
            }
        }

        function flipCamera() {
            ++currentVideoDeviceIdx;
            if (currentVideoDeviceIdx >= videoDevices.length) {
                currentVideoDeviceIdx = 0;
            }
            console.log(`videoDevices[${currentVideoDeviceIdx}] = ${videoDevices[currentVideoDeviceIdx]}`);

            setUpCamera();
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

        function recordVideo() {

        }
    </script>
</head>
<body onload="init();">
<%--Ideally these elements aren't created until it's confirmed that the --%>
<%--client supports video/camera, but for the sake of illustrating the --%>
<%--elements involved, they are created with markup (not JavaScript)--%>
<video id="video" width="640" height="480" autoplay></video>
<button id="flipCamera" onclick="flipCamera()">Flip Camera</button>
<button id="snap" onclick="takePhoto()">Snap Photo</button>
<button id="snap" onclick="recordVideo()">Record</button>
<canvas id="canvas" width="640" height="480"></canvas>
</body>
</html>
