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

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServlet;

// SignOn DAO Imports (Petstore Lite: replaces the SignOn EJB)
import com.sun.j2ee.blueprints.signon.dao.UserDAO;
import com.sun.j2ee.blueprints.signon.dao.UserDAOException;
import com.sun.j2ee.blueprints.signon.dao.DuplicateUserException;

/**
 * Creates a new customer user from the sign on page and signs the user on.
 *
 * Validation rules:
 *  - user name is 3 to 25 characters, letters, digits, '-' and '_' only
 *  - password is 4 to 25 characters
 *  - password and confirmation must match
 *  - user name must not already exist
 */
public class CreateUserServlet extends HttpServlet {

    public static final String FORM_PASSWORD_CONFIRM =«REDACTED:secret-finding-11»
    public static final String USER_CREATION_ERROR = "j_user_creation_error";
    public static final String USER_CREATION_ERROR_PAGE = "user_creation_error.screen";

     public  void doPost(HttpServletRequest request, HttpServletResponse  response)
        throws IOException, ServletException {

        // get the user name
        String userName = request.getParameter(SignOnFilter.FORM_USER_NAME);
        // get the password
        String password =«REDACTED:secret-finding-12»
        String passwordConfirm =«REDACTED:secret-finding-13»

        String error = validate(userName, password, passwordConfirm);
        if (error != null) {
            request.getSession().setAttribute(USER_CREATION_ERROR, error);
            response.sendRedirect(USER_CREATION_ERROR_PAGE);
            return;
        }

        UserDAO userDAO = new UserDAO();
        try {
            userDAO.createUser(userName, password, request.getRemoteAddr());
            System.out.println("CreateUserServlet create user: username=" + userName);
            request.getSession().setAttribute(SignOnFilter.USER_NAME, userName);
            request.getSession().setAttribute(SignOnFilter.SIGNED_ON_ROLE, UserDAO.ROLE_CUSTOMER);
            request.getSession().setAttribute(SignOnFilter.SIGNED_ON_USER, new Boolean(true));
            // redirect to the original destination
            String targetURL = (String)request.getSession().getAttribute(SignOnFilter.ORIGINAL_URL);
            if (targetURL == null) targetURL = SignOnFilter.DEFAULT_TARGET_URL;
            response.sendRedirect(targetURL);
        } catch (DuplicateUserException de) {
            request.getSession().setAttribute(USER_CREATION_ERROR, "The user name " + userName + " is already taken. Choose another user name.");
            response.sendRedirect(USER_CREATION_ERROR_PAGE);
        } catch (UserDAOException ue) {
            throw new ServletException("CreateUserServlet: " + ue.getMessage());
        }
     }

     private String validate(String userName, String password, String passwordConfirm) {
        if (userName == null || userName.trim().length() < UserDAO.MIN_USERNAME_LENGTH
            || userName.trim().length() > UserDAO.MAX_USERNAME_LENGTH) {
            return "The user name must be " + UserDAO.MIN_USERNAME_LENGTH + " to " + UserDAO.MAX_USERNAME_LENGTH + " characters.";
        }
        for (int i = 0; i < userName.length(); i++) {
            char c = userName.charAt(i);
            if (!Character.isLetterOrDigit(c) && c != '-' && c != '_') {
                return "The user name can only contain letters, digits, '-' and '_'.";
            }
        }
        if (password =«REDACTED:secret-finding-14»
            || password.length() > UserDAO.MAX_PASSWORD_LENGTH) {
            return "The password must be " + UserDAO.MIN_PASSWORD_LENGTH + " to " + UserDAO.MAX_PASSWORD_LENGTH + " characters.";
        }
        if (!password.equals(passwordConfirm)) {
            return "The password and the confirmation do not match.";
        }
        return null;
     }
}
