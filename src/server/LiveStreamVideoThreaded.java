package server;

import javax.websocket.*;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.*;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@ServerEndpoint(value = "/liveStreamVideoThreaded")
public class LiveStreamVideoThreaded {
    private static final Set<Session> sessions = Collections.synchronizedSet(new HashSet<Session>());
    private static Map<String, Vector<Session>> classMap = Collections.synchronizedMap(new HashMap<String, Vector<Session>>());

    @OnMessage
    public void processVideo(byte[] imageData, Session session) {
        try {
            // Wrap a byte array into a buffer
            ByteBuffer buffer = ByteBuffer.wrap(imageData);

            // Find the vector containing all the users in the current class
            String qString = session.getQueryString();
            String[] split = qString.split("class=");
            String courseName = split[1];

            Vector<Session> connections = new Vector<>(classMap.get(courseName));
            // do not send message back to the sender
            connections.remove(session);

            if (connections.isEmpty()) {
                return;
            }

            int numThreads = connections.size() / Runtime.getRuntime().availableProcessors();
            if (numThreads < 1)
                numThreads = 1;

            ExecutorService executor = Executors.newFixedThreadPool(3);
            for (int i = 1; i <= numThreads; ++i) {
                int offset = numThreads / 8;
                offset = offset <= 0 ? 1 : offset;
                executor.execute(new SendingThread(buffer, new Vector<>(connections.subList(i - offset, i))));
            }
            executor.shutdown();
            while (!executor.isTerminated()) {
                Thread.yield();
            }
        } catch (Throwable ioe) {
            System.out.println("Error sending message " + ioe.getMessage());
        }

    }

    @OnOpen
    public void whenOpening(Session session) throws IOException, EncodeException {
        // Split the query string and get the class parameter
        String qString = session.getQueryString();
        String[] split = qString.split("class=");
        String courseName = split[1];

        // Try and find the vector with the name as the key
        Vector<Session> connections = classMap.get(courseName);
        // If none found, create a new entry with the name
        if (connections == null) {
            System.out.println("adding class - " + courseName);
            Vector<Session> newConnections = new Vector<Session>();
            newConnections.add(session);
            classMap.put(courseName, newConnections);
        }
        // If found, insert session into the vector
        else {
            System.out.println("adding session into " + courseName);
            connections.add(session);
        }

        session.setMaxBinaryMessageBufferSize(1024 * 1024);
        sessions.add(session);
    }

    @OnError
    public void onError(Throwable error) {
        System.out.println("Error!");
        error.printStackTrace();
    }

    @OnClose
    public void whenClosing(Session session) {
        // Remove session from vector containing all the sessions
        System.out.println("Session " + session.getId() + " disconnected!");
        sessions.remove(session);

        // Find the session in the map and remove it
        String qString = session.getQueryString();
        String[] split = qString.split("class=");
        String courseName = split[1];
        Vector<Session> allConnections = classMap.get(courseName);
        allConnections.remove(session);
    }
}
