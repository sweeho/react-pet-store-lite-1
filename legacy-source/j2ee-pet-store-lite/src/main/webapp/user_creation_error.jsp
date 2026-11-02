<%--
 Copyright 2002 Sun Microsystems, Inc. All rights reserved.
 Redistribution and use subject to the license in LICENSE-SUN.txt.
--%>
<%@ taglib prefix="c" uri="/WEB-INF/c.tld" %>
<p class="petstore_title">Could Not Create Your Account</p>
<p class="petstore_error"><c:out value="${j_user_creation_error}"/></p>
<p class="petstore">Please <a href="signon_welcome.screen">go back</a> and try again.</p>
