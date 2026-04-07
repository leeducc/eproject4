import { useEffect, useRef, useState } from "react";
import Stomp from "stompjs";

interface WebRtcSignalMessage {
    type: "offer" | "answer" | "ice-candidate";
    data: any;
    fromUser: string;
    toUser: string;
}

export const useWebRTC = (
    currentUserId: string,
    stompClient: Stomp.Client | null
) => {
    const [localStream, setLocalStream] = useState<MediaStream | null>(null);
    const [remoteStream, setRemoteStream] = useState<MediaStream | null>(null);
    const peerConnection = useRef<RTCPeerConnection | null>(null);
    const targetUserId = useRef<string | null>(null);

    const configuration: RTCConfiguration = {
        iceServers: [{ urls: "stun:stun.l.google.com:19302" }],
    };

    const initializePeerConnection = () => {
        if (peerConnection.current) return;

        console.log("[WebRTC] Initializing PeerConnection");
        const pc = new RTCPeerConnection(configuration);

        pc.onicecandidate = (event) => {
            if (event.candidate && targetUserId.current) {
                sendSignal({
                    type: "ice-candidate",
                    data: event.candidate,
                    fromUser: currentUserId,
                    toUser: targetUserId.current,
                });
            }
        };

        pc.ontrack = (event) => {
            console.log("[WebRTC] New Remote Track received");
            if (event.streams && event.streams[0]) {
                setRemoteStream(event.streams[0]);
            }
        };

        if (localStream) {
            localStream.getTracks().forEach((track) => {
                pc.addTrack(track, localStream);
            });
        }

        peerConnection.current = pc;
    };

    const getLocalMedia = async () => {
        try {
            const stream = await navigator.mediaDevices.getUserMedia({
                video: true,
                audio: true,
            });
            setLocalStream(stream);
            return stream;
        } catch (err) {
            console.error("[WebRTC] Failed to get user media", err);
            return null;
        }
    };

    const sendSignal = (message: WebRtcSignalMessage) => {
        if (stompClient?.connected) {
            stompClient.send("/app/tutoring/rtc/signal", {}, JSON.stringify(message));
        }
    };

    const startCall = async (toUser: string) => {
        targetUserId.current = toUser;
        initializePeerConnection();
        
        if (!peerConnection.current) return;

        const offer = await peerConnection.current.createOffer();
        await peerConnection.current.setLocalDescription(offer);

        console.log("[WebRTC] Sending Offer to student:", toUser);
        sendSignal({
            type: "offer",
            data: offer,
            fromUser: currentUserId,
            toUser: toUser,
        });
    };

    const handleSignal = async (signal: WebRtcSignalMessage) => {
        if (!peerConnection.current) {
            initializePeerConnection();
        }

        const pc = peerConnection.current!;

        if (signal.type === "offer") {
            await pc.setRemoteDescription(new RTCSessionDescription(signal.data));
            const answer = await pc.createAnswer();
            await pc.setLocalDescription(answer);
            sendSignal({
                type: "answer",
                data: answer,
                fromUser: currentUserId,
                toUser: signal.fromUser,
            });
        } else if (signal.type === "answer") {
            await pc.setRemoteDescription(new RTCSessionDescription(signal.data));
        } else if (signal.type === "ice-candidate") {
            try {
                await pc.addIceCandidate(new RTCIceCandidate(signal.data));
            } catch (e) {
                console.warn("[WebRTC] Error adding ICE candidate", e);
            }
        }
    };

    const closeConnection = () => {
        if (peerConnection.current) {
            peerConnection.current.close();
            peerConnection.current = null;
        }
        if (localStream) {
            localStream.getTracks().forEach(track => track.stop());
            setLocalStream(null);
        }
        setRemoteStream(null);
        targetUserId.current = null;
    };

    useEffect(() => {
        return () => closeConnection();
    }, []);

    return {
        localStream,
        remoteStream,
        getLocalMedia,
        startCall,
        handleSignal,
        closeConnection
    };
};
