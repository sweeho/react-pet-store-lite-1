/*
 * Copyright 2002 Sun Microsystems, Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 *
 * - Redistribution in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in
 *   the documentation and/or other materials provided with the
 *   distribution.
 *
 * Neither the name of Sun Microsystems, Inc. or the names of
 * contributors may be used to endorse or promote products derived
 * from this software without specific prior written permission.
 *
 * This software is provided "AS IS," without a warranty of any
 * kind. ALL EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND
 * WARRANTIES, INCLUDING ANY IMPLIED WARRANTY OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE OR NON-INFRINGEMENT, ARE HEREBY
 * EXCLUDED. SUN AND ITS LICENSORS SHALL NOT BE LIABLE FOR ANY DAMAGES
 * SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR
 * DISTRIBUTING THE SOFTWARE OR ITS DERIVATIVES. IN NO EVENT WILL SUN
 * OR ITS LICENSORS BE LIABLE FOR ANY LOST REVENUE, PROFIT OR DATA, OR
 * FOR DIRECT, INDIRECT, SPECIAL, CONSEQUENTIAL, INCIDENTAL OR
 * PUNITIVE DAMAGES, HOWEVER CAUSED AND REGARDLESS OF THE THEORY OF
 * LIABILITY, ARISING OUT OF THE USE OF OR INABILITY TO USE SOFTWARE,
 * EVEN IF SUN HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
 *
 * You acknowledge that Software is not designed, licensed or intended
 * for use in the design, construction, operation or maintenance of
 * any nuclear facility.
 */

package com.sun.j2ee.blueprints.signon.web;

import java.io.PrintWriter;
import java.io.OutputStreamWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;
import java.net.URL;

// J2EE imports
import javax.servlet.ServletException;
import javax.servlet.ServletContext;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.http.HttpSession;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Cookie;

// SignOn DAO Imports (Petstore Lite: replaces the SignOn EJB)
import com.sun.j2ee.blueprints.signon.dao.UserDAO;
import com.sun.j2ee.blueprints.signon.dao.UserDAOException;


public class SignOnFilter implements Filter {

    // these static strings define where to put/get things
    public static final String FORM_SIGNON_URL = "j_signon_check";
    public static final String FORM_USER_NAME = "j_username";
    public static final String FORM_PASSWORD =«REDACTED:secret-finding-15»
    public static final String REMEMBER_USERNAME = "j_remember_username";
    public static final String USER_NAME = "j_signon_username";
    public static final String SIGNED_ON_USER  = "j_signon";
    public static final String ORIGINAL_URL = "j_signon_original_url";
    public static final String CREATE_USER_URL = "j_create_user";
    public static final String COOKIE_NAME = "bp_signon";
    public static final String SIGNED_ON_ROLE = "j_signon_role";
    public static final String LOCKED_PAGE = "signon_locked.screen";
    public static final String ACCESS_DENIED_PAGE = "access_denied.screen";
    public static final String DEFAULT_TARGET_URL = "main.screen";


    private HashMap protectedResources;
    private FilterConfig config = null;
    private String signOnErrorPage = null;
    private String signOnPage = null;
    private String userCreationError = null;

    public void init(FilterConfig config) throws ServletException {
        this.config = config;
        URL protectedResourcesURL = null;
        try {
            protectedResourcesURL = config.getServletContext().getResource("/WEB-INF/signon-config.xml");
            if (protectedResourcesURL != null) {
                SignOnDAO dao = new SignOnDAO(protectedResourcesURL);
                signOnErrorPage = dao.getSignOnErrorPage();
                signOnPage = dao.getSignOnPage();
                protectedResources = dao.getProtectedResources();
            }
        } catch (java.net.MalformedURLException ex) {
            System.err.println("SignonFilter: malformed URL exception: " + ex);
        }
    }

    public void destroy() {
        config = null;
    }

     public  void doFilter(ServletRequest request, ServletResponse  response, FilterChain chain)
        throws IOException, ServletException {
        HttpServletRequest hreq = (HttpServletRequest)request;
        String currentURI = hreq.getRequestURL().toString();
        String currentURL = hreq.getRequestURI();
        // get everything after the context root
        int firstSlash = currentURL.indexOf("/",1); // jump past the starting slash
        String targetURL = null;
        if (firstSlash != -1) targetURL = currentURL.substring(firstSlash + 1, currentURL.length());

        if ((targetURL != null) && targetURL.equals(FORM_SIGNON_URL)) {
            validateSignOn(request, response, chain);
            // jump out of this method
            return;
        }

        // check if the user is signed on
        boolean signedOn = false;
        if (hreq.getSession().getAttribute(SIGNED_ON_USER) != null) {
            signedOn =((Boolean)hreq.getSession().getAttribute(SIGNED_ON_USER)).booleanValue();
        } else {
            hreq.getSession().setAttribute(SIGNED_ON_USER, new Boolean(false));
        }
        // jump to the resource if signed on and the user's role is allowed
        if (signedOn) {
                ProtectedResource resource = findProtectedResource(targetURL);
                if (resource != null && !isRoleAllowed(resource, (String)hreq.getSession().getAttribute(SIGNED_ON_ROLE))) {
                    config.getServletContext().getRequestDispatcher("/" + ACCESS_DENIED_PAGE).forward(request, response);
                    return;
                }
                chain.doFilter(request,response);
                return;
        }
        // find out if the patterns match the target URL
        Iterator it = null;
        if (protectedResources != null) it = protectedResources.keySet().iterator();
        while ((it != null) && it.hasNext()) {
            String protectedName = (String)it.next();
            ProtectedResource resource  = (ProtectedResource)protectedResources.get(protectedName);
            String urlPattern = resource.getURLPattern();

            // now check agains the targetURL
            if (urlPattern.equals(targetURL)) {
                // put the orginal url in the session so others can access
                hreq.getSession().setAttribute(ORIGINAL_URL,  targetURL);
                config.getServletContext().getRequestDispatcher("/" + signOnPage).forward(request, response);
                // Jump out of the filter and go to the next page
                return;
            }
        }
        // No matches if we made it to here
        chain.doFilter(request,response);
    }

     public  void validateSignOn(ServletRequest request, ServletResponse  response, FilterChain chain)
        throws IOException, ServletException {
        // convert to a http servlet request for now
        HttpServletRequest hreq = (HttpServletRequest)request;
        HttpServletResponse hres = (HttpServletResponse)response;
        // get the user name
        String userName = hreq.getParameter(FORM_USER_NAME);
        // get the password
        String password =«REDACTED:secret-finding-16»
        // check if the user wants userName set in cookie
        String rememberUserName = hreq.getParameter(REMEMBER_USERNAME);
        if (rememberUserName != null) {
          // set a cookie with the username in it
          Cookie userNameCookie = new Cookie(COOKIE_NAME, userName);
          // set cookie to last for one month
          userNameCookie.setMaxAge(2678400);
          hres.addCookie(userNameCookie);
        } else {
            // see if the cookie exists and remove accordingly
            Cookie[] cookies = hreq.getCookies();
            if (cookies != null) {
                for (int loop=0; loop < cookies.length; loop++) {
                    if (cookies[loop].getName().equals(COOKIE_NAME)) {
                        cookies[loop].setMaxAge(0);
                        hres.addCookie(cookies[loop]);

                    }
                }
            }
        }

        //validate against the registered users
        UserDAO userDAO = new UserDAO();
        int result;
        String role = null;
        try {
            result = userDAO.authenticate(userName, password, hreq.getRemoteAddr());
            if (result == UserDAO.SIGNON_OK) role = userDAO.getRole(userName);
        } catch (UserDAOException ue) {
            throw new ServletException("SignOnFilter: sign on failed: " + ue.getMessage());
        }
        if (result == UserDAO.SIGNON_OK) {
            // place a true boolean in the session
            if (hreq.getSession().getAttribute(USER_NAME) != null) {
                hreq.getSession().removeAttribute(USER_NAME);
            }
            hreq.getSession().setAttribute(USER_NAME, userName);
            hreq.getSession().setAttribute(SIGNED_ON_ROLE, role);
            // remove the sign on user key before putting it back in
            if (hreq.getSession().getAttribute(SIGNED_ON_USER) != null) {
                hreq.getSession().removeAttribute(SIGNED_ON_USER);
            }
            hreq.getSession().setAttribute(SIGNED_ON_USER, new Boolean(true));
            // redirect to the original destination
            String targetURL = (String)hreq.getSession().getAttribute(ORIGINAL_URL);
            if (targetURL == null) targetURL = DEFAULT_TARGET_URL;
            hres.sendRedirect(targetURL);
            return;
        } else if (result == UserDAO.SIGNON_LOCKED) {
            hres.sendRedirect(LOCKED_PAGE);
            return;
        } else {
            hres.sendRedirect(signOnErrorPage);
            return;
        }
     }

     private ProtectedResource findProtectedResource(String targetURL) {
        Iterator it = null;
        if (protectedResources != null) it = protectedResources.values().iterator();
        while ((it != null) && it.hasNext()) {
            ProtectedResource resource = (ProtectedResource)it.next();
            if (resource.getURLPattern().equals(targetURL)) return resource;
        }
        return null;
     }

     /**
      * A resource with no roles in its auth-constraint is open to any
      * signed on user. Otherwise the user's role must be listed.
      */
     private boolean isRoleAllowed(ProtectedResource resource, String role) {
        if (resource.getRoles() == null || resource.getRoles().isEmpty()) return true;
        return role != null && resource.getRoles().contains(role);
     }
}
