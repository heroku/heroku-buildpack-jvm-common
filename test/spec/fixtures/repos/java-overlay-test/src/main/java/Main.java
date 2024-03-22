import javax.servlet.http.*;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.servlet.*;

public class Main extends HttpServlet {

  public static void main(String[] args) throws Exception{
    Server server = new Server(Integer.parseInt(System.getenv("PORT")));
    ServletContextHandler context = new ServletContextHandler(ServletContextHandler.SESSIONS);
    context.setContextPath("/");
    server.setHandler(context);
    context.addServlet(new ServletHolder(new HelloServlet()),"/*");
    server.start();
    server.join();
  }
}
