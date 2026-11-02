<%--
 Copyright 2002 Sun Microsystems, Inc. All rights reserved.
 Redistribution and use subject to the license in LICENSE-SUN.txt.
--%>
<%@ taglib prefix="c" uri="/WEB-INF/c.tld" %>
<p class="petstore_title">Sign In</p>
<p class="petstore"><b>Are you a returning customer?</b></p>
<table cellpadding="20" cellspacing="0" border="1">
 <tr>
  <td valign="top">
   <form name="existingcustomer" action="j_signon_check" method="POST">
    <table cellpadding="5" cellspacing="0" border="0">
     <tr>
      <td class="petstore" align="center" colspan="2">
       <b>Yes.</b>
      </td>
     </tr>
     <tr>
      <td class="petstore_form" align="right">
       <b>User Name:</b>
      </td>
      <td class="petstore_form">
       <c:choose>
        <c:when test="${cookie['bp_signon'] != null && cookie['bp_signon'] != ''}">
         <input class="petstore_form" type="text" size="15" name="j_username" value="<c:out value="${cookie['bp_signon'].value}"/>">
        </c:when>
        <c:otherwise>
         <input class="petstore_form" type="text" size="15" name="j_username" value="j2ee">
        </c:otherwise>
       </c:choose>
      </td>
     </tr>
     <tr>
      <td class="petstore_form" align="right">
       <b>Password:</b>
      </td>
      <td class="petstore_form">
       <input class="petstore_form" type="password" size="15" name="j_password" value="">
      </td>
     </tr>
     <tr>
      <td align="center" colspan="2">
       <input class="petstore_form" name="submit" type="submit" value="Sign In">
      </td>
     </tr>
     <tr>
      <td class="petstore_form" align="center" colspan="2">
       Remember My User Name
       <c:choose>
        <c:when test="${cookie['bp_signon'] != null && cookie['bp_signon'] != ''}">
         <input type="checkbox" name="j_remember_username" checked>
        </c:when>
        <c:otherwise>
         <input type="checkbox" name="j_remember_username">
        </c:otherwise>
       </c:choose>
      </td>
     </tr>
    </table>
   </form>
  </td>
  <td valign="top">
   <form name="newcustomer" action="createuser.do" method="POST">
    <table cellpadding="5" cellspacing="0" border="0">
     <tr>
      <td class="petstore" align="center" colspan="2">
       <b>No. I would like to sign up for an account.</b>
      </td>
     </tr>
     <tr>
      <td class="petstore_form" align="right">
       <b>User Name:</b>
      </td>
      <td class="petstore_form">
       <input class="petstore_form" type="text" size="15" name="j_username">
      </td>
     </tr>
     <tr>
      <td class="petstore_form" align="right">
       <b>Password:</b>
      </td>
      <td class="petstore_form">
       <input class="petstore_form" type="password" size="15" name="j_password">
      </td>
     </tr>
     <tr>
      <td class="petstore_form" align="right">
       <b>Password (Repeat):</b>
      </td>
      <td class="petstore_form">
       <input class="petstore_form" type="password" size="15" name="j_password_confirm">
      </td>
     </tr>
     <tr>
      <td align="center" colspan="2">
       <input class="petstore_form" name="submit" type="submit" value="Create New Account">
      </td>
     </tr>
     <tr>
      <td class="petstore_form" align="center" colspan="2">
       User name: 3 to 25 letters, digits, '-' or '_'.<br>
       Password: 4 to 25 characters.
      </td>
     </tr>
    </table>
   </form>
  </td>
 </tr>
</table>
