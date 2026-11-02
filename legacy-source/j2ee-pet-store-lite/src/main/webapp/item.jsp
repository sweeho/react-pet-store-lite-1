<%--
 Copyright 2002 Sun Microsystems, Inc. All rights reserved.
 Redistribution and use subject to the license in LICENSE-SUN.txt.
--%>
<%@ taglib prefix="c" uri="/WEB-INF/c.tld" %>
<%@ taglib prefix="fmt" uri="/WEB-INF/fmt.tld" %>

<jsp:useBean
  id="catalog"
  class="com.sun.j2ee.blueprints.catalog.client.CatalogHelper"
  scope="session"
/>

<c:set value="en_US" target="${catalog}" property="locale"/>
<c:set value="${param.item_id}" target="${catalog}" property="itemId"/>
<c:set value="${catalog.item}" var="item" />

<p class="petstore_title">
 <c:out value="${item.attribute}"/>
 <c:out value="${item.productName}"/>
</p>
<fmt:setLocale value="en_US" />
<table cellpadding="2" cellspacing="0" border="0" width="100%">
 <tr>
  <td><img src='images/<c:out value="${item.imageLocation}"/>'></td>
  <td class="petstore" width="100%"><b>List Price:</b>
   <fmt:formatNumber value="${item.listCost}" type="currency" />
   <br><br>
   <b>Your Price:</b>
   <fmt:formatNumber value="${item.unitCost}" type="currency" />
   <br><br>
   <c:out value="${item.description}"/>
   <br><br>
   <b>Item ID:</b> <c:out value="${item.itemId}"/>
  </td>
 </tr>
</table>
