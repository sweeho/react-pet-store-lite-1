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

package com.sun.j2ee.blueprints.signon.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

/**
 * JDBC data access for the SIGNON and SIGNON_AUDIT tables.
 * Petstore Lite: replaces the SignOn session bean and the User CMP
 * entity bean of Pet Store 1.3.2.
 *
 * Business rules:
 *  - a user that fails MAX_FAILED_ATTEMPTS sign-ons in a row is locked
 *  - a locked user cannot sign on, even with the right password, until
 *    the PSL_ACCT_UNLOCK batch job (or an administrator) clears the lock
 *  - every sign-on attempt, sign-off and new user is written to SIGNON_AUDIT
 */
public class UserDAO {

    public static final String DATASOURCE = "java:comp/env/jdbc/CatalogDB";

    public static final int MAX_FAILED_ATTEMPTS = 3;
    public static final int MIN_USERNAME_LENGTH = 3;
    public static final int MAX_USERNAME_LENGTH = 25;
    public static final int MIN_PASSWORD_LENGTH =«REDACTED:secret-finding-7»
    public static final int MAX_PASSWORD_LENGTH =«REDACTED:secret-finding-8»

    public static final String ROLE_CUSTOMER = "CUSTOMER";
    public static final String ROLE_ADMIN = "ADMIN";

    // results of authenticate()
    public static final int SIGNON_OK = 0;
    public static final int SIGNON_INVALID = 1;
    public static final int SIGNON_LOCKED = 2;

    // SIGNON_AUDIT.EVENT_TYPE values
    public static final String EVENT_SIGNON_OK = "SIGNON_OK";
    public static final String EVENT_SIGNON_FAIL = "SIGNON_FAIL";
    public static final String EVENT_ACCOUNT_LOCKED = "ACCOUNT_LOCKED";
    public static final String EVENT_SIGNON_LOCKED = "SIGNON_LOCKED";
    public static final String EVENT_SIGNOFF = "SIGNOFF";
    public static final String EVENT_USER_CREATED = "USER_CREATED";

    private static final String SELECT_USER =
        "select password, role, failed_attempts, locked from signon where username =«REDACTED:secret-finding-9»
    private static final String UPDATE_SUCCESS =
        "update signon set failed_attempts = 0, last_signon = ? where username = ?";
    private static final String UPDATE_FAILURE =
        "update signon set failed_attempts = ?, locked = ?, locked_ts = ? where username = ?";
    private static final String INSERT_USER =
        "insert into signon (username, password, role, failed_attempts, locked, created_ts) values (?, ?, ?, 0, 'N', ?)";
    private static final String INSERT_AUDIT =
        "insert into signon_audit (username, event_type, event_ts, remote_addr) values (?, ?, ?, ?)";
    private static final String SELECT_AUDIT =
        "select event_type, event_ts, remote_addr from signon_audit where username = ? order by event_ts desc, audit_id desc";

    /**
     * Check the user name and password and apply the lockout rule.
     * Returns SIGNON_OK, SIGNON_INVALID or SIGNON_LOCKED.
     */
    public int authenticate(String userName, String password, String remoteAddr) throws UserDAOException {
        Connection connection = null;
        try {
            connection = getConnection();
            PreparedStatement select = connection.prepareStatement(SELECT_USER);
            select.setString(1, userName);
            ResultSet rs = select.executeQuery();
            if (!rs.next()) {
                rs.close();
                select.close();
                audit(connection, userName, EVENT_SIGNON_FAIL, remoteAddr);
                return SIGNON_INVALID;
            }
            String storedPassword =«REDACTED:secret-finding-10»
            int failedAttempts = rs.getInt(3);
            boolean locked = "Y".equals(rs.getString(4));
            rs.close();
            select.close();

            if (locked) {
                audit(connection, userName, EVENT_SIGNON_LOCKED, remoteAddr);
                return SIGNON_LOCKED;
            }
            Timestamp now = new Timestamp(System.currentTimeMillis());
            if (storedPassword.equals(password)) {
                PreparedStatement update = connection.prepareStatement(UPDATE_SUCCESS);
                update.setTimestamp(1, now);
                update.setString(2, userName);
                update.executeUpdate();
                update.close();
                audit(connection, userName, EVENT_SIGNON_OK, remoteAddr);
                return SIGNON_OK;
            }
            failedAttempts++;
            boolean lockNow = failedAttempts >= MAX_FAILED_ATTEMPTS;
            PreparedStatement update = connection.prepareStatement(UPDATE_FAILURE);
            update.setInt(1, failedAttempts);
            update.setString(2, lockNow ? "Y" : "N");
            update.setTimestamp(3, lockNow ? now : null);
            update.setString(4, userName);
            update.executeUpdate();
            update.close();
            audit(connection, userName, EVENT_SIGNON_FAIL, remoteAddr);
            if (lockNow) {
                audit(connection, userName, EVENT_ACCOUNT_LOCKED, remoteAddr);
                return SIGNON_LOCKED;
            }
            return SIGNON_INVALID;
        } catch (SQLException se) {
            throw new UserDAOException("UserDAO.authenticate: " + se.getMessage());
        } finally {
            close(connection);
        }
    }

    /**
     * Create a new customer user. Throws DuplicateUserException if the
     * user name is taken.
     */
    public void createUser(String userName, String password, String remoteAddr)
        throws UserDAOException, DuplicateUserException {
        Connection connection = null;
        try {
            connection = getConnection();
            PreparedStatement select = connection.prepareStatement(SELECT_USER);
            select.setString(1, userName);
            ResultSet rs = select.executeQuery();
            boolean exists = rs.next();
            rs.close();
            select.close();
            if (exists) {
                throw new DuplicateUserException(userName);
            }
            PreparedStatement insert = connection.prepareStatement(INSERT_USER);
            insert.setString(1, userName);
            insert.setString(2, password);
            insert.setString(3, ROLE_CUSTOMER);
            insert.setTimestamp(4, new Timestamp(System.currentTimeMillis()));
            insert.executeUpdate();
            insert.close();
            audit(connection, userName, EVENT_USER_CREATED, remoteAddr);
        } catch (SQLException se) {
            throw new UserDAOException("UserDAO.createUser: " + se.getMessage());
        } finally {
            close(connection);
        }
    }

    public String getRole(String userName) throws UserDAOException {
        Connection connection = null;
        try {
            connection = getConnection();
            PreparedStatement select = connection.prepareStatement(SELECT_USER);
            select.setString(1, userName);
            ResultSet rs = select.executeQuery();
            String role = rs.next() ? rs.getString(2).trim() : null;
            rs.close();
            select.close();
            return role;
        } catch (SQLException se) {
            throw new UserDAOException("UserDAO.getRole: " + se.getMessage());
        } finally {
            close(connection);
        }
    }

    public void recordSignOff(String userName, String remoteAddr) throws UserDAOException {
        Connection connection = null;
        try {
            connection = getConnection();
            audit(connection, userName, EVENT_SIGNOFF, remoteAddr);
        } catch (SQLException se) {
            throw new UserDAOException("UserDAO.recordSignOff: " + se.getMessage());
        } finally {
            close(connection);
        }
    }

    /**
     * Returns the latest audit events for a user, newest first, as a List
     * of Maps with keys eventType, eventTime and remoteAddr.
     */
    public List getRecentActivity(String userName, int count) throws UserDAOException {
        Connection connection = null;
        List events = new ArrayList();
        try {
            connection = getConnection();
            PreparedStatement select = connection.prepareStatement(SELECT_AUDIT);
            select.setString(1, userName);
            ResultSet rs = select.executeQuery();
            while (rs.next() && events.size() < count) {
                Map event = new HashMap();
                event.put("eventType", rs.getString(1).trim());
                event.put("eventTime", rs.getTimestamp(2));
                event.put("remoteAddr", rs.getString(3));
                events.add(event);
            }
            rs.close();
            select.close();
            return events;
        } catch (SQLException se) {
            throw new UserDAOException("UserDAO.getRecentActivity: " + se.getMessage());
        } finally {
            close(connection);
        }
    }

    private void audit(Connection connection, String userName, String eventType, String remoteAddr)
        throws SQLException {
        PreparedStatement insert = connection.prepareStatement(INSERT_AUDIT);
        insert.setString(1, userName);
        insert.setString(2, eventType);
        insert.setTimestamp(3, new Timestamp(System.currentTimeMillis()));
        insert.setString(4, remoteAddr);
        insert.executeUpdate();
        insert.close();
    }

    private Connection getConnection() throws UserDAOException {
        try {
            InitialContext ic = new InitialContext();
            DataSource ds = (DataSource) ic.lookup(DATASOURCE);
            return ds.getConnection();
        } catch (NamingException ne) {
            throw new UserDAOException("UserDAO: cannot find data source " + DATASOURCE + ": " + ne.getMessage());
        } catch (SQLException se) {
            throw new UserDAOException("UserDAO: cannot open connection: " + se.getMessage());
        }
    }

    private void close(Connection connection) {
        try {
            if (connection != null) connection.close();
        } catch (SQLException se) {
            // ignore
        }
    }
}
