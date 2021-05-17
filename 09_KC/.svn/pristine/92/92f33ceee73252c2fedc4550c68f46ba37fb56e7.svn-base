/**
 * @file ose.h Declarations of Oracle Sync Engine APIs
 */

#ifndef OSE_H
#define OSE_H

/**
 * Prefix "ose" (or "OSE_" for constants) stands for "Oracle Sync Engine" and
 * is used for Oracle Sync Engine API types, constants and functions.
 */

/********************************************//**
 *  OSE Types and Constants
 ***********************************************/

#ifdef __x86_64        /* Add other 64-bit targets here */
#ifndef BUILD_64BIT    /* To avoid redefinition warnings */
#define BUILD_64BIT
#endif
#endif

typedef char oseBool; /**< boolean type */
#define OSE_TRUE 1 /**< constant for value "true" */
#define OSE_FALSE 0 /**< constant for value "false" */

typedef char ose1B; /**< 1 byte signed integer */
typedef unsigned char oseU1B; /**< 1 byte unsigned integer */
typedef short ose2B; /**< 2 byte signed integer */
typedef unsigned short oseU2B; /**< 2 byte unsigned integer */
#ifdef BUILD_64BIT
typedef int ose4B; /**< 4 byte signed integer */
typedef unsigned int oseU4B; /**< 4 byte unsigned integer */
#else
typedef long ose4B; /**< 4 byte signed integer */
typedef unsigned long oseU4B; /**< 4 byte unsigned integer */
#endif
#ifdef _MSC_VER
typedef __int64 ose8B; /**< 8 byte signed integer */
typedef unsigned __int64 oseU8B; /**< 8 byte unsigned integer */
#else
typedef long long ose8B; /**< 8 byte signed integer */
typedef unsigned long long oseU8B; /**< 8 byte unsigned integer */
#endif

#define OSE_MAX_USER	32 /**< maximum length of sync user name */

typedef ose1B osePrio; /**< sync data priority */
typedef long oseError; /**< sync error code */
typedef ose4B oseSize; /**< OSE size type akin to size_t */

/**
 * Error descriptor structure pointer to which is assigned by the function
 * @link <oseGetLastError>. If the error has an underlying cause,
 * the oseErrorDesc.cause will point to another oseErrorDesc structure,
 * which in turn can have its own cause, etc.  This is especially useful if
 * OSE call returns OSE_ERR_INTERNAL_ERROR .  If cause is not present,
 * oseErrorDesc.cause will be NULL (this is a boundary condition for iteration
 * through all error descriptors)
 * The memory for oseErrorDesc structure is allocated within
 * sync engine and should not be be freed by application.
 */
typedef struct _oseErrorDesc {
	oseError code; /**< error code, for OSE errors @see oseError.h */
	const char *type; /**< a string describing the type of error */
	const char *msg; /**< error message */
	struct _oseErrorDesc *cause; /**< underlying cause, if present */
} oseErrorDesc;

typedef void *oseSess; /**< OSE session handle */

/** Sync direction constants */

/** Bidirectional sync, this is the default */
#define OSE_SYNC_DIR_SENDRECEIVE	0
/** Data is only sent, but not received */
#define OSE_SYNC_DIR_SEND			1
/** Data is only received, but not sent */
#define OSE_SYNC_DIR_RECEIVE		2

/**
 * Encryption type constants
 * They indicate how the data is encrypted
 * when transfered over the network.
 */

/** Encrypt using AES */
#define OSE_ENC_TYPE_AES			0
/** Use HTTPS protocol, so the data will go through secure sockets */
#define OSE_ENC_TYPE_SSL			1
/** No encryption */
#define OSE_ENC_TYPE_NONE			2

/**
 * Sync transport type constants.
 * Transport type designates the protocol used to transfer data
 * to/from mobile server.
 */

/** Data is transfered using HTTP protocol */
#define OSE_TR_TYPE_HTTP			0
/** Data is transfered by the custom transport provided by the application
 * @see oseTransport
 */
#define OSE_TR_TYPE_USER			1
/** Data is transfered manually using files (file-based sync) */
#define OSE_TR_TYPE_FILE			2

/** Transport direction constants
 * This is used to indicate connected or disconnected (e.g. file-based) sync.
 */

/**
 * Connected sync, this is the default.
 * Note that this can be with either bidirectional or unidirectional sync.
 * For instance, if sync direction is set to OSE_SYNC_DIR_SEND, it will
 * indicate send-only sync over connected transport (data is sent and
 * acknowledgement is received).
 */
#define OSE_TR_DIR_SENDRECEIVE		0

/**
 * Disconnected sync, send-only.  Data is sent without acknowledgement.
 * This can currently be used only with transport type OSE_TR_TYPE_FILE.
 */
#define OSE_TR_DIR_SEND				1

/**
 * Disconnected sync, receive-only.
 * This can currently be used only with transport type OSE_TR_TYPE_FILE.
 */
#define OSE_TR_DIR_RECEIVE			2

/**
 * Sync priority constants.  Currently only two priorities are supported,
 * high and normal.
 */
#define OSE_PRIO_HIGH				0 /**< high priority */
#define OSE_PRIO_DEFAULT			1 /**< normal priority */
#define OSE_PRIO_LOWEST             OSE_PRIO_DEFAULT

/**
 * Sync options.
 * When the session is created, the initial value for each option can be
 * either: default value specified below for numeric options, NULL for string
 * options, loaded from ose.ini configuration file as specified below for some
 * options or loaded from OSE Meta files saved on the previous sync as
 * specified below for some options.  Every option, except
 * OSE_OPT_NEW_PASSWORD is set for the duration of the session (not just
 * the next sync), unless it is explicitly reset later.  New values for
 * options loaded from OSE Meta files (e.g. OSE_OPT_URL, OSE_OPT_PROXY)
 * will be saved in OSE Meta files during next sync.
 */

/**
 * Numeric sync options. Includes boolean options as well.
 * For boolean options use values OSE_TRUE and OSE_FALSE.
 * @see oseSetNumOption
 * @see oseGetNumOption
 */

/** Sync direction, see sync direction constants */
#define OSE_OPT_SYNC_DIRECTION		0

/** Encryption type, see sync direction constants */
#define OSE_OPT_ENCRYPTION_TYPE		1

/** Transport type, see transport type constants */
#define OSE_OPT_TRANSPORT_TYPE		2

/** Transport direction, see transport direction constants */
#define OSE_OPT_TRANSPORT_DIRECTION	3

/**
 * Boolean option, indicates whether user sync password should be saved
 * on the client so it doesn't have to be explicitely provided to future
 * sessions.
 * The password is saved in encrypted form.
 */
#define OSE_OPT_SAVE_PASSWORD		4

/**
 * Boolean option, indicates whether next sync should be background.
 * OSE_FALSE is the default, indicating foreground sync. Foreground sync
 * implicitely performs compose and apply for each database involved,
 * in addition to sync.
 * Background sync does not perform compose or apply, and also does not do
 * snapshot DDL (create/drop snapshot, create new publication).
 */
#define OSE_OPT_BACKGROUND			5

/** Sync priority, see sync priority constants */
#define OSE_OPT_SYNC_PRIO			6

/**
 * Boolean option, indicates whether sync should download a list of
 * application/client updates so they can later be installed.
 * OSE_TRUE is the default.
 * @see OSE_OPT_HAS_SOFT_UPDATES
 */
#define OSE_OPT_SYNC_APPS			7

/**
 * Boolean option, indicates whether new publication(s) can be created
 * during sync.  OSE_TRUE is the default.
 */
#define OSE_OPT_SYNC_NEW_PUB		8

/**
 * Boolean option, indicates if the sync is force-refresh.  This ignores
 * client changes and reloads all client data from mobile server.
 * OSE_FALSE is the default.
 */
#define OSE_OPT_FORCE_REFRESH		9

/**
 * @deprecated { use sync direction OSE_SYNC_DIR_SEND }
 */
#define OSE_OPT_PUSH_ONLY			10

/*
 * Boolean option, indicates whether files are used to temporarily store
 * the data before it's sent/after it's received.  If enabled, client changes
 * will first be saved into a file ("oseOutFile.bin" by default), then sent to
 * mobile server, then the received data will be saved to another file
 * ("oseInFile.bin" by default) and then read and transfered to database(s)
 * from that file.  Typically this is used for resume transport or for
 * protocols where the total data size to be sent needs to be known in advance
 * (e.g. HTTP 1.0).
 * OSE_FALSE is the default.
 * ose.ini parameter: OSE.FILES=TRUE|FALSE
 * @see OSE_OPT_RESUME_TRANSPORT
 */
#define OSE_OPT_USE_FILES			11

/**
 * Boolean option, indicates whether resume protocol should be used on top
 * of sync transport.  Currently needs OSE_OPT_USE_FILES enabled
 * (OSE_OPT_USE_FILES will be set implicitly when this option is used).
 * Resume protocol is typically used for lengthy sync sessions over unstable
 * network connections.  It allows to resume sending/receiveing data from the
 * point of network disconnect, thus avoiding the restart of sync from scratch
 * in case the network temporarily disconnected.  This option is used only
 * with connected transport (OSE_TR_DIR_SENDRECEIVE).
 * OSE_FALSE is the default.
 * ose.ini parameter: OSE.RESUME=TRUE|FALSE
 */
#define OSE_OPT_RESUME_TRANSPORT	12

/**
 * Boolean read-only option (do not use with oseSetNumOption) which indicates
 * whether any updates are available for the client after the last sync.
 * This flags is currently used by "msync" tool which will launch "update"
 * utility when it exits, in case updates are available.
 * @see OSE_OPT_SYNC_APPS
 */
#define OSE_OPT_HAS_SOFT_UPDATES    13

/**
 * Boolean option, indicates whether databases newly created during sync
 * should be encrypted.  The encryption key for each database is either
 * retrieved from the sync keystore, or generated based on sync password,
 * if not found in the keystore.  Applications can define their own keys
 * for each database (before its created during sync) by using the keystore
 * APIs.
 * OSE_FALSE is the default.
 * ose.ini parameter: OSE.ENCRYPTDB=TRUE|FALSE
 * @see oseSetDBKey
 * @see oseGetDBKey
 * @see oseRemoveDBKey
 */
#define OSE_OPT_ENCRYPT_DATABASES	14

/**
 * Boolean option, indicates whether to perform a special setup sync,
 * where the mobile server sends only the snapshot metadata
 */
#define OSE_OPT_SETUP_SYNC			15


/**
 * String (character) sync options.
 * If not loaded during session init, every option except OSE_OPT_APP_ROOT
 * defaults to NULL.
 * @see oseSetStrOption
 * @see oseGetStrOption
 */

/**
 * Mobile server url.
 * Present in OSE Meta files.
 */
#define	OSE_OPT_URL					100

/**
 * Http proxy if present, in the format "host:port" or "host",
 * in which case the port defaults to 80.
 * Present in OSE Meta files.
 */
#define OSE_OPT_PROXY				101

/**
 * New password provided to change sync password during the next sync.
 * This option needs to be set each time the password needs to be changed.
 */
#define OSE_OPT_NEW_PASSWORD		102

/**
 * Read-only option, used to get sync user name.
 * Present in OSE Meta files.
 */
#define OSE_OPT_USER_NAME			103

/**
 * Write-only option, used to set sync password in the current session.
 * Will overwrite the value provided to oseOpenSession or retrieved from
 * OSE configuration files.  Usually only used to set sync password in case
 * NULL password was passed to oseOpenSession
 * Saved in OSE Meta files if OSE_OPT_SAVE_PASSWORD was enabled.
 * @see oseOpenSession
 */
#define OSE_OPT_PASSWORD			104

/**
 * Root directory for internal sync files. By default, it is the sync client
 * installation bin directory.
 */
#define	OSE_OPT_APP_ROOT			105

/**
 * File url for file-based sync.  Path to the file optionally prefixed by
 * "file://"
 */
#define OSE_OPT_FILE_URL			106

/**
 * User-defined progress callback declarations.
 * Usually used to display progress of sync operation in UI.
 * @see oseSetProgress
 */

/** Sync states(stages) used by user-defined progress callback */

/** No sync happening */
#define OSE_SYNC_STATE_IDLE			0

/**
 * Preparing data into temporary file.
 * Only used if OSE_OPT_USE_FILES is enabled.
 * @see OSE_OPT_USE_FILES
 */
#define OSE_SYNC_STATE_PREPARE		1

/** Sending data to mobile server */
#define OSE_SYNC_STATE_SEND			2

/** Receiving data from mobile server */
#define OSE_SYNC_STATE_RECEIVE		3

/**
 * Processing data from temporary file.
 * Only used if OSE_OPT_USE_FILES is enabled.
 * @see OSE_OPT_USE_FILES
 */
#define OSE_SYNC_STATE_PROCESS		4

/** Context handle used to store callback's state data */
typedef void *oseUserCtx;

/**
 * Callback function pointer type declaration.
 * @param ctx callback's context handle
 * @param stage one of the stage values defined above
 * @param val percentage completed for a given stage (0-100)
 * @return currently return value is ignored
 */
typedef oseError (* oseProgressFunc)(oseUserCtx ctx, int stage, int val);

/**
 * User-defined sync transport declarations.
 * @see OSE_TR_TYPE_USER
 */

/** Transport environment handle used to store transport's state data */
typedef void *oseTrEnv;

/** Transport function pointer type declarations */

/**
 * Begin sending data.
 * @param env transport environment handle
 * @return 0 if successful, negative value if transport error has occurred
 */
typedef oseError (* oseTrBeginWrite)(oseTrEnv env);

/**
 * Finish sending data.
 * @param env transport environment handle
 * @return 0 if successful, negative value if transport error has occurred
 */
typedef oseError (* oseTrEndWrite)(oseTrEnv env);

/**
 * Begin receiving data.
 * @param env transport environment handle
 * @return 0 if successful, negative value if transport error has occurred
 */
typedef oseError (* oseTrBeginRead)(oseTrEnv env);

/**
 * Finish receiving data.
 * @param env transport environment handle
 * @return 0 if successful, negative value if transport error has occurred
 */
typedef oseError (* oseTrEndRead)(oseTrEnv env);

/**
 * Send data
 * @param env transport environment handle
 * @param buf pointer to buffer to write
 * @param len number of bytes to write
 * @return 0 if successful, negative value if transport error has occurred
 */
typedef oseError (* oseTrWrite)(oseTrEnv env, const void *buf,
	oseSize len);

/**
 * Receive data
 * @param env transport environment handle
 * @param buf pointer to buffer to read into
 * @param len size of the buffer
 * @param retLen stores number of bytes actually received
 * @return 0 if successful, negative value if transport error has occurred
 */
typedef oseError (* oseTrRead) (oseTrEnv env, void *buf,
	oseSize len, oseSize *retLen);

/**
 * Get transport error message from the last call, if any
 * @param env transport environment handle
 * @param e error code from the last call
 * @param buf pointer to buffer to store the error message
 * @param bufSize buffer size
 */
typedef oseError (* oseTrGetError)(oseTrEnv env, oseError e,
	char *buf, oseSize bufSize);

/**
 * Structure containing environment and function pointers to the
 * user-defined transport functions.
 * @see oseSetUserTransport
 */
typedef struct _oseTransport {
	oseTrEnv env; /**< transport environment handle */
	oseTrBeginWrite beginWrite; /**< definition of oseTrBeginWrite */
	oseTrEndWrite endWrite; /**< definition of oseTrEndWrite */
	oseTrBeginRead beginRead; /**< definition of oseTrBeginRead */
	oseTrEndRead endRead; /**< definition of oseTrEndRead */
	oseTrWrite write; /**< definition of oseTrWrite */
	oseTrRead read; /**< definition of oseTrRead */
	oseTrGetError getError; /**< definition of oseTrGetError */
} oseTransport;

/********************************************//**
 *  OSE APIs
 ***********************************************/

#ifdef _WIN32
#define OSE_EXPORT __declspec(dllexport)
#define OSE_IMPORT __declspec(dllimport)
#else
#define OSE_EXPORT
#define OSE_IMPORT
#endif

#ifdef IN_OSE
#define OSE_API OSE_EXPORT
#else
#define OSE_API OSE_IMPORT
#endif

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Open new OSE session.  Note that in multithreaded environment a single
 * OSE session is not supposed to be used concurrently from multiple threads.
 * Each thread should open its own session, even for the same user. The only
 * exception to this is oseCancelSync.
 * @param user sync user name.  If NULL, last saved user name will be used.
 * If last user was not recored, OSE_ERR_USER_NOT_SPECIFIED is returned
 * @param pwd sync password.  If NULL, saved password for this user will
 * be used if it was previously saved.  Alternatively, the password can
 * be specified later with OSE_OPT_PASSWORD option.  If, at the time of sync,
 * the password is still not specified and was not previously saved,
 * OSE_ERR_PWD_NOT_SPECIFIED will be returned.
 * @param sess pointer to a session handle to return new session into,
 * can't be NULL
 * @return 0 if successful,
 * OSE error code if failed
 * @see oseCancelSync
 * @see oseerr.h
 * @see OSE_OPT_PASSWORD
 */
OSE_API oseError oseOpenSession(const char *user, const char *pwd,
	oseSess *sess);

/**
 * Close OSE session.  Free session resources.
 * @param sess session handle
 * @return 0 if successful
 * OSE_ERR_INVALID_SESS if session handle was invalid
 * @see oseerr.h
 */
OSE_API oseError oseCloseSession(oseSess sess);

/**
 * Set numeric option.
 * @param sess session handle
 * @ param opt option code
 * @ param val option value
 * @ return 0 if set successfully,
 * OSE error code if invalid option code
 * specified, or invalid value specified for particular option
 * @see Numeric sync options
 * @see oseerr.h
 */
OSE_API oseError oseSetNumOption(oseSess sess, int opt, long val);

/**
 * Get numeric option
 * @param sess session handle
 * @param opt option code
 * @param val pointer to a variable to return value into, can't be NULL
 * @return 0, if successful,
 * OSE_ERR_INVALID_INT_OPT if invalid option code specified
 @ see Numeric sync options
 * @see oseerr.h
 */
OSE_API oseError oseGetNumOption(oseSess sess, int opt, long *val);

/**
 * Set string option.
 * @param sess session handle
 * @ param opt option code
 * @ param val option value
 * @ return 0 if set successfully,
 * OSE error code if invalid option code specified or invalid value specified
 * for particular option
 * @see String sync options
 * @see oseerr.h
 */
OSE_API oseError oseSetStrOption(oseSess sess, int opt, const char *val);

/**
 * Get string option
 * @param sess session handle
 * @param opt option code
 * @param val buffer to retrive the value into
 * @bufSize size of the buffer
 * @return 0, if successful,
 * OSE_ERR_INVALID_STR_OPT if invalid option code specified,
 * OSE_ERR_INVALID_BUFFER if buffer was too small to store the value
 * (together with null-terminating character)
 * @see String sync options
 * @see oseerr.h
 */
OSE_API oseError oseGetStrOption(oseSess sess, int opt,
	char *val, int bufSize);

/**
 * Get string option without copying. The memory for the option value is
 * stored within OSE engine and is valid until next call to oseGetStrOptionNC
 * @param sess session handle
 * @param opt option code
 * @param val pointer to a character pointer into which return the value,
 * can't be NULL
 * @return 0 if successful,
 * OSE_ERR_INVALID_STR_OPT if invalid option code specified
 * @see String sync options
 * @see oseerr.h
 */
OSE_API oseError oseGetStrOptionNC(oseSess sess, int opt, const char **val);

/**
 * Sets user transport.  This will automatically set OSE_OPT_TRANSPORT_TYPE to
 * OSE_TR_TYPE_USER
 * @param sess session handle
 * @param tr pointer to the user transport structure
 * @return 0 if successful
 * OSE_ERR_INVALID_SESS if session handle was invalid
 * @see oseerr.h
 * @see User-defined sync transport declarations
 */
OSE_API oseError oseSetUserTransport(oseSess sess, const oseTransport *tr);

/**
 * Sets sync progress callback.
 * @param sess session handle
 * @param ctx user context handle
 * @param pf progress function pointer
 * @return 0 if successful
 * OSE_ERR_INVALID_SESS if session handle was invalid
 * @see User-defined progress callback declarations
 * @see oseerr.h
 */
OSE_API oseError oseSetProgress(oseSess sess, oseUserCtx ctx,
	oseProgressFunc pf);

/**
 * Provides database connection handle from the application to
 * use in OSE engine, instead of engine opening its own database connection,
 * which is default.  The connection handle is set for the duration of
 * the session unless explicitly unset by the same call with NULL
 * connection handle value.
 * @param sess session handle
 * @param db database name for which connection handle is provided
 * @connHdl connection handle
 * connHdl has to be valid database connection handle for a particular type
 * of database as used in the OSE plugin.  For example, for sqlite and BDB
 * plugins connHdl value should be of type "sqlite3 *"
 * NUll value will unshare the connection, that is make OSE engine
 * open its own database connection again
 * @return 0 if successfully shared
 * OSE_ERR_PLUGIN_ERROR if plugin error has occured, the underlying plugin
 * error can be retrieved by oseGetLastError
 * @see oseerr.h
 * @see oseGetLastEror
 * @see sqlitePluginErr.h for sqlite and bdb plugin error codes
 */
OSE_API oseError oseShareConnection(oseSess sess, const char *db,
    void *connHdl);

/*
 * Get database encryption key from the OSE key store
 * @param sess session handle
 * @param db database name for which retrieve the key
 * @buf buffer to store the key
 * @bufSize size of the buffer
 * @retLen actual key length
 * retLen will be 0 if the key was not found
 * @return 0 if successful
 * OSE_ERR_INVALID_BUFFER if the buffer was too small to store the key
 * OSE_ERR_INTERNAL_ERROR if internal error occured in the key store
 * @see oseerr.h
 * @see OSE_OPT_ENCRYPT_DATABASES
 */
OSE_API oseError oseGetDBKey(oseSess sess, const char *db,
	void *buf, oseSize bufSize, oseSize *retLen);

/**
 * Set database encryption key in the OSE key store.
 * This is used when application wants to encrypt each database with
 * custom key instead of using a key generated from sync password.
 * Subsequently, the key in the key store will be used by OSE engine to
 * open the database after it was created.  Applications also need to use
 * this call when they reencrypt the database with a different key so that
 * OSE engine has the correct key to access the database during sync.
 * @param sess session handle
 * @param db database name for which set the key
 * @param key buffer with provided key
 * @param keyLen provided key size
 * @return 0 if successful
 * OSE_ERR_INTERNAL_ERROR if internal error occured in the key store
 * @see oseerr.h
 * @see OSE_OPT_ENCRYPT_DATABASES
 */
OSE_API oseError oseSetDBKey(oseSess sess, const char *db,
	const void *key, oseSize keyLen); 

/**
 * Remove database encryption key from OSE key store
 * @param sess session handle
 * @param db database name for which remove the key
 * @return 0 if successful
 * OSE_ERR_INTERNAL_ERROR if internal error occured in the key store
 * @see oseerr.h
 * @see OSE_OPT_ENCRYPT_DATABASES
 */
OSE_API oseError oseRemoveDBKey(oseSess sess, const char *db);

/**
 * Select publication for selective sync.  Selective sync allows only
 * certain publications to be synced and not others.  Application can
 * select publications needed by repeatedly calling oseSelectPub.  To revert
 * to regular (non-selective) sync, call this function with NULL publication
 * name.
 * @param sess session handle
 * @pub publication name to select
 * NULL will deselect all publications (revert back to non-selective sync)
 * @return 0 if successful
 * OSE_ERR_PUB_NOT_FOUND if publication with given name was not found
 * @see oseerr.h
 */
OSE_API oseError oseSelectPub(oseSess sess, const char *pub);

/**
 * Saves user information into OSE Meta files.  The information includes
 * publications, snapshots, databases, mobile server url, proxy, etc.
 * Usually this is done at the end of sync if changes are detected.
 * This call allows to do it explicitly, in case the information has to be
 * saved before sync.  Password will be saved only if OSE_OPT_SAVE_PASSWORD
 * is enabled.
 * @param sess session handle
 * @return 0 if successful,
 * OSE_ERR_INTERNAL_ERROR if IO error occured during saving
 * @see OSE_OPT_SAVE_PASSWORD
 * @see oseerr.h
 */
OSE_API oseError oseSaveUser(oseSess sess);

/**
 * Performs sync operation synchronously.
 * @param sess session handle
 * @return 0 if sync is successful
 * OSE_ERR_INVALID_SESS if session handle was invalid
 * OSE_ERR_SYNC_CANCELED if sync was canceled from another thread by
 * oseCancelSync
 * other OSE error code if sync failed
 * @see oseerr.h
 */
OSE_API oseError oseSync(oseSess sess);

/**
 * Cancels sync operation from another thread. This call returns immediately,
 * while there is no guarantee on how long it will take for the sync operation
 * to abort.
 * @param sess session handle
 * @return 0 if successful
 * OSE_ERR_INVALID_SESS if session handle was invalid
 */
OSE_API oseError oseCancelSync(oseSess sess);

/**
 * Get extended error information from last OSE call.  This information
 * contains the last OSE error info as well as any internal errors that
 * caused it.
 * @param sess session handle
 * can be NULL if trying to retrieve error information from failed
 * oseOpenSession call
 * @param errDesc pointer to oseErrorDesc pointer into which oseErrorDesc
 * pointer will be returned.  Cannot be NULL. Note that the structures
 * referenced by this pointer are only valid until next OSE call.
 * @return 0 if successful
 * OSE_ERR_INVALID_SESS if session handle was invalid
 * OSE_ERR_INTERNAL_ERROR if system error has occured
 * @see oseErrorDesc
 * @see oseerr.h
 */
OSE_API oseError oseGetLastError(oseSess sess, const oseErrorDesc **errDesc);

/**
 * Set initialization parameter in ose.ini (or ose.txt) configuration file.
 * This is a generic routine to set parameter for any sync component based on
 * component name (category) and parameter name.
 * Note that the new parameter value will only take effect when new OSE session
 * is opened.
 * @param cat parameter category (e.g. OSE, SQLITE, BGSYNC, NETWORK)
 * @param name parameter name (e.g. RESUME, DATA_DIRECTORY, etc.)
 * @param val parameter value represented as string.  If the given parameter
 * already exists in ose.ini, its value will be overwritten by val.
 * @return 0 if successful
 * OSE_ERR_INTERNAL_ERROR if ose.ini file could not be modified or saved
 * Cause will have more info
 */
OSE_API oseError oseSetParam(const char *cat, const char *name,
    const char *val);

 /**
  * Get initialization parameter value from ose.ini (or ose.txt)
  * configuration file.
  * This is a generic routine to get parameter value for any sync component
  * based on component name (category) and parameter name.
  * The parameter value is retrieved without copying.  The memory for the
  * parameter value is stored within OSE engine and is valid until the next
  * call to oseGetParamNC
  * @param cat parameter category (e.g. OSE, SQLITE, BGSYNC, NETWORK)
  * @param name parameter name (e.g. RESUME, DATA_DIRECTORY, etc.)
  * @param val pointer to a character pointer into which return the value,
  * can't be NULL.  If given parameter does not exist in ose.ini, pointer
  * pointed to by val will be set to NULL
  * @return 0 if successful
  * OSE_ERR_INTENRAL_ERROR if ose.ini file could not be read
  * Cause will have more info
  */
OSE_API oseError oseGetParamNC(const char *cat, const char *name,
    const char **val);

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif /* OSE_H */
