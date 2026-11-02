<%--
 Copyright 2002 Sun Microsystems, Inc. All rights reserved.
 Redistribution and use subject to the license in LICENSE-SUN.txt.
--%>
<%@ taglib prefix="c" uri="/WEB-INF/c.tld" %>
 <table bgcolor="#FFFFFF" width="100%" cellpadding="0" cellspacing="0" border="0">
  <tr>
   <td align="left" valign="middle">
    <a href="main.screen">
     <img src="images/banner_logo.gif" alt="Java Pet Store Demo logo" border="0">
    </a>
   </td>
   <td class="petstore" align="right" valign="middle">
     <form action="search.screen">
      <input class="petstore_listing" type="text" name="keywords" size="8">
      <input class="petstore_listing" type="submit" value="Search">
    </form>
    <br>
    <c:if test="${j_signon == true}">
     Signed in as <b><c:out value="${j_signon_username}"/></b> |
    </c:if>
    <a href="account.screen">Account</a>
    <c:if test="${j_signon_role == 'ADMIN'}">
     | <a href="populate_admin.screen">Admin</a>
    </c:if>
     |
    <c:choose>
     <c:when test="${j_signon == true}"><a href="signoff.do">Sign out</a></c:when>
     <c:otherwise><a href="signon_welcome.screen">Sign in</a></c:otherwise>
    </c:choose>
  </td>
 </tr>
  <tr>
   <td colspan="2">
    <hr noshade="noshade" size="1">
   </td>
  </tr>
 </table>
