<%--
 Copyright 2002 Sun Microsystems, Inc. All rights reserved.
 Redistribution and use subject to the license in LICENSE-SUN.txt.
--%>
<p class="petstore_title">Catalog Administration</p>
<p class="petstore">Reloading the sample data drops and recreates every catalog and
sign-on table, then loads the categories, products, items and users from
<code>populate/Populate-UTF8.xml</code>.</p>
<p class="petstore_error">All accounts created in the store and all sign-in
history are deleted. You will be signed out.</p>
<form action="Populate" method="POST">
 <input type="hidden" name="forcefully" value="true">
 <input type="hidden" name="success_page" value="main.screen">
 <input class="petstore_form" type="submit" value="Reload Sample Data">
</form>
