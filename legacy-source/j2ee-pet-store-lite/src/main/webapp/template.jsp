<%--
 Copyright 2002 Sun Microsystems, Inc. All rights reserved.
 Redistribution and use subject to the license in LICENSE-SUN.txt.
--%>
<%@ taglib uri="/WEB-INF/template.tld" prefix="template" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
 <head>
  <style type="text/css">
   .petstore {
    font-family: Helvetica, Arial, sans-serif;
    font-size: small;
   }
   .petstore_title {
    font-family: Helvetica, Arial, sans-serif;
    font-weight: bold;
    }
   .petstore_footer {
    font-family: Helvetica, Arial, sans-serif;
    font-size: x-small;
   }
   .petstore_listing {
    font-family: Helvetica, Arial, sans-serif;
    font-size: x-small;
   }
   .petstore_form {
    font-family: Helvetica, Arial, sans-serif;
    font-size: x-small;
   }
   .petstore_error {
    font-family: Helvetica, Arial, sans-serif;
    font-size: small;
    color: #CC0000;
   }
  </style>
  <title><template:insert parameter="title" /></title>
 </head>
 <body bgcolor="#FFFFFF">
  <table width="100%" border="0" cellpadding="5" cellspacing="0">
   <tr height="100" valign="top">
    <td colspan="2"><template:insert parameter="banner" /></td>
   </tr>
   <tr valign="top">
     <td width="20%" valign="top"><template:insert parameter="sidebar" /></td>
     <td width="80%" valign="top"><template:insert parameter="body" /></td>
   </tr>
   <tr>
    <td colspan="2"><template:insert parameter="footer" /></td>
   </tr>
  </table>
 </body>
</html>
