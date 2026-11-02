<%--
 Copyright 2002 Sun Microsystems, Inc. All rights reserved.
 Redistribution and use subject to the license in LICENSE-SUN.txt.
--%>
<%@ taglib prefix="c" uri="/WEB-INF/c.tld" %>
<%@ taglib prefix="fmt" uri="/WEB-INF/fmt.tld" %>
<jsp:useBean
  id="account"
  class="com.sun.j2ee.blueprints.signon.web.AccountHelper"
  scope="request"
/>
<c:set value="${j_signon_username}" target="${account}" property="userName"/>
<p class="petstore_title">My Account</p>
<table cellpadding="2" cellspacing="0" border="0">
 <tr>
  <td class="petstore"><b>User Name:</b></td>
  <td class="petstore"><c:out value="${account.userName}"/></td>
 </tr>
 <tr>
  <td class="petstore"><b>Role:</b></td>
  <td class="petstore"><c:out value="${account.role}"/></td>
 </tr>
</table>
<p class="petstore_title">Recent Sign-in Activity</p>
<table border="0" width="100%" cellpadding="1" cellspacing="0">
<tr>
<td bgcolor="#808080">
<table width="100%" cellspacing="0" cellpadding="2" border="0" bgcolor="#FFFFFF">
 <tr bgcolor="#336666">
  <td class="petstore_listing"><font color="#FFFFFF"><b>When</b></font></td>
  <td class="petstore_listing"><font color="#FFFFFF"><b>Event</b></font></td>
  <td class="petstore_listing"><font color="#FFFFFF"><b>From</b></font></td>
 </tr>
 <c:forEach var="event" items="${account.recentActivity}">
 <tr>
  <td class="petstore_listing"><fmt:formatDate value="${event.eventTime}" pattern="yyyy-MM-dd HH:mm:ss"/></td>
  <td class="petstore_listing"><c:out value="${event.eventType}"/></td>
  <td class="petstore_listing"><c:out value="${event.remoteAddr}"/></td>
 </tr>
 </c:forEach>
</table>
</td>
</tr>
</table>
<p class="petstore_listing">Showing your 10 most recent events.</p>
