<%--
 Copyright 2002 Sun Microsystems, Inc. All rights reserved.
 Redistribution and use subject to the license in LICENSE-SUN.txt.
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="/WEB-INF/c.tld" %>


<jsp:useBean
  id="catalog"
  class="com.sun.j2ee.blueprints.catalog.client.CatalogHelper"
  scope="session"
/>

<c:set value="en_US" target="${catalog}" property="locale"/>
<c:set value="5" target="${catalog}" property="count"/>
<c:set value="0" target="${catalog}" property="start"/>

<table border="0" width="100%" cellpadding="1" cellspacing="0">
 <tr>
  <td bgcolor="#336666" class="petstore_title" align="center">
   <font color="#FFFFFF">Pets</font>
  </td>
 </tr>
 <tr>
  <td bgcolor="#336666">
   <table border="0" width="100%" cellpadding="5" cellspacing="1">
    <tr>
     <td bgcolor="#FFFFFF" class="petstore">
      <c:forEach var="item" items="${catalog.categories.list}" >
       <a href="category.screen?category_id=<c:out value="${item.id}" />">
        <c:out value="${item.name}" />
       </a>
       <br>
      </c:forEach>
     </td>
    </tr>
   </table>
  </td>
 </tr>
</table>
