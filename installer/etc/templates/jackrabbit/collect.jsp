<%--
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
--%><%@ page import="javax.jcr.Repository,
                 javax.jcr.Session,
                  org.apache.jackrabbit.core.SessionImpl,
                  org.apache.jackrabbit.core.data.GarbageCollector,
                 org.apache.jackrabbit.j2ee.RepositoryAccessServlet,
                 org.apache.jackrabbit.util.Text,
                 javax.jcr.SimpleCredentials,
                   java.util.Calendar,
                   java.text.NumberFormat"
%><%@ page contentType="text/html;charset=UTF-8" %><%
    request.setAttribute("title", "Garbage Collection");
    %><jsp:include page="header.jsp"/>
    <form name=f action="collect.jsp" method="POST">
      <table border=0 cellpadding=0 cellspacing=0 width=100%>
        <tr><td valign=middle>
        <input type="hidden" name="doit" value="true"/>
        <INPUT type=submit VALUE="Perform&nbsp;Garbage&nbsp;Collection...">
        </td></tr>
      </table>
    </form><%
    Repository rep;
    Session jcrSession;
    StringBuffer sb = new StringBuffer();
    if(null!=request.getParameter("doit") && "true".equals(request.getParameter("doit"))){
    try {
        rep = RepositoryAccessServlet.getRepository(pageContext.getServletContext());
        jcrSession = rep.login();
    } catch (Throwable e) {
        %>Error while accessing the repository: <font color="red"><%= Text.encodeIllegalXMLCharacters(e.getMessage()) %></font><br><%
        %>Check the configuration or use the <a href="admin/">easy setup</a> wizard.<%
        return;
    }
    GarbageCollector gc;
    try {
    SessionImpl si = (SessionImpl) jcrSession;
out.println("Create garbage collector...<br>");

                gc = si.createDataStoreGarbageCollector();

// optional (if you want to implement a progress bar / output):
//                gc.setScanEventListener(this);
out.println("Got collector, starting scan...<br>");
                gc.scan();
out.println("Stopping scan...<br>");
                gc.stopScan();

// delete old data
out.println("Deleting old data..<br>");
                int unused=gc.deleteUnused();
out.println("finished deleting ("+unused+")<br>");

    } finally {
        if (jcrSession != null) {
            jcrSession.logout();
        }
    }

}
        %>
<jsp:include page="footer.jsp"/>
