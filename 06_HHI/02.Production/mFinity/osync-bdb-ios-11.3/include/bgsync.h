/**
 * @file bgsync.h Declarations of Oracle Sync Agent Control APIs,
 * otherwise called BG APIs.
 */

#ifndef BGSYNC_H
#define BGSYNC_H

#include "ose.h"
#include "bgmsg.h"

/**
 * Prefix "bg" (or "BG_" for constants) stands for "Background" and is used
 * for Sync Agent Control API types, constants and functions.
 */

/********************************************//**
 *  BG Types and Constants
 ***********************************************/

typedef void *bgSess; /**< BG session handle */

/**
 * BG error code. Same as oseError.
 * @see oseError in ose.h
 */
typedef oseError bgError;

/**
 * Error descriptor structure, same as oseErrorDesc.  Retrieved by
 * bgGetLastError
 * @see oseErrorDesc in ose.h
 * @see oseGetLastError in ose.h
 * @see bgGetLastError
 */
typedef oseErrorDesc bgErrorDesc;

/**
 * Sync Agent control command codes
 * @see bgControlAgent
 */

/**
 * Start syncagent.
 * If the agent is in state BG_STATUS_RUNNING, BG_STATUS_START_PENDING or
 * BG_STATUS_RESUME_PENDING this command has no effect.  If the syncagent is
 * in state BG_STATUS_PAUSED, this command will resume it.
 * @see status codes
 */
#define BG_CTRL_START						0

/**
 * Stop syncagent.
 * If syncagent is in state BG_STATUS_STOPPED or BG_STATUS_STOP_PENDING
 * this command has no effect.
 * @see status codes
 */
#define BG_CTRL_STOP						1

/**
 * Pause syncagent.
 * If syncagent is in state BG_STATUS_PAUSED or BG_STATUS_PAUSE_PENDING
 * this command has no effect.
 * @see status codes
 */
#define BG_CTRL_PAUSE						2

/**
 * Resume syncagent.
 * If syncagent is in state BG_STATUS_RUNNING, BG_STATUS_START_PENDING or
 * BG_STATUS_RESUME_PENDING this command has no effect.
 * @see status codes
 */
#define BG_CTRL_RESUME						3

/** Not yet supported for native clients */
#define BG_CTRL_SHOW_UI						4

/** Not yet supported for native clients */
#define BG_CTRL_HIDE_UI						5

/**
 * Options for "start" command
 * @see bgControlAgent
 */

/**
 * Start syncagent within the current process.  By default, when this flag is
 * not set, syncagent is started in a separate process named "syncagent"
 * ("syncagent.exe" on Windows platforms)
 */
#define BG_CTRL_OPT_START_INTERNAL			0x1

/**
 * Options for "stop" command
 * @see bgControlAgent
 */

/**
 * Kill syncagent process instead of trying to stop it gracefully.  Use this
 * only as a last resort (for example if some tasks within syncagent are
 * hanging so that the regular "stop" command is not working.  Also not
 * advisable to use if syncagent was started with BG_CTRL_OPT_START_INTERNAL
 * option.
 */
#define BG_CTRL_OPT_TERMINATE				0x1

/** Sync Agent Status declarations */

/** status codes */

#define BG_STATUS_STOPPED					0 /**< not running */
#define BG_STATUS_START_PENDING				1 /**< starting */
#define BG_STATUS_RUNNING					2 /**< running */
#define BG_STATUS_PAUSE_PENDING				3 /**< pausing */
#define BG_STATUS_PAUSED					4 /**< paused */
#define BG_STATUS_RESUME_PENDING			5 /**< resuming */
#define BG_STATUS_STOP_PENDING				6 /**< stopping */
#define BG_STATUS_DEFUNCT					7 /**< internal state of error */

/** represents unknown numeric value for numeric status fields */ 
#define BG_UNKNOWN_VALUE                    -1

/**
 * bgAgentStatus structure contains general status information for syncagent.
 * This information is retrieved via call to bgGetAgentStatus.
 * @see bgGetAgentStatus
 */
typedef struct _bgAgentStatus {
	/** Status code */
	ose1B statusCode;
	/** Whether syncgent was started in separate process */
	oseBool isExternal;
	oseU2B _reserved; /**< for alignment */
	/** Sync user name for which syncagent is running */
	const char *clientId;
	/** Process name within which syncagent is running */
	const char *processName;
	/** Current network name as detected by syncagent */
	const char *networkName;
	/** Process id of the process in which syncagent is running */
	ose4B processId;
	/**
	 * Current network bandwidth as detected by syncagent
	 * BG_UNKNOWN_VALUE if bandwidth cannot be determined
	 */
	ose4B networkSpeed;
	/**
	 * Current battery life (in %) as detected by syncagent
	 * 100 if battery is not present (desktop compurer)
	 * BG_UNKNOWN_VALUE if battery life cannot be determined
	 */
	ose4B batteryPower;
} bgAgentStatus;

/** Status per publication, currently not supported */
typedef struct _bgPubStatus {
	const char *pubName;
	const char *dbName;
	ose8B composeTime;
	ose8B syncTime;
	ose8B applyTime;
} bgPubStatus;

/**
 * bgSyncStatus structure contains status information of sync
 * (last or ongoing) within syncagent.  This information is retrieved
 * via bgGetSyncStatus.
 * The status is either for the ongoing sync if one is currently in progress
 * or for the last sync that happened within syncagent.
 * @see bgGetSyncStatus
 */
typedef struct _bgSyncStatus {
	/** Number of publications synced */
	oseSize pubCnt;
	/**
	 * Array of publcation names of publications synced. Number of elements
	 * in this array is indicated by pubCnt. Can be NULL if sync has not
	 * happened yet.
	 */
	const char **pubs;
	/**
	 * Sync priority
	 * @see Sync priority constants in ose.h
	 */
	osePrio prio;
	oseU1B _reserved[3]; /**< for alignment */
	/**
	 * Sync start time in milliseconds since the epoch, as in java,
	 * Value 0 indicates that sync has not happened yet.
	 */
	ose8B startTime;
	/**
	 * Sync finish time in milliseconds sinc the epoch
	 * Value 0 means sync is currently in progress (unless startTime is also 0
	 * meaning sync has not happened yet)
	 */
	ose8B endTime;
	/**
	 * Last sync error code or 0 if last sync was successful or sync has
	 * not yet happened
	 */
	oseError res;
	/** Last sync error message or NULL if not applicable */
	const char *errMsg;
	/**
	 * Current sync stage name
	 * @see Sync state strings in bgmsg.h
	 */
	const char *stateName;
	/**
	 * Current sync stage
	 * OSE_SYNC_STATE_IDLE if sync is not in progress
	 */
	ose2B state;
	/** Current sync progress value or 0 if not applicable */
	ose2B progress;
} bgSyncStatus;

/** Sync Agent message and callback declarations */

/** Message types */
#define BG_MSG_TYPE_INFO						0 /**< information message */
#define BG_MSG_TYPE_WARNING						1 /**< warning */
#define BG_MSG_TYPE_ERROR						2 /**< error */

/**
 * bgMsg structure contains message information, passed to the callbacks
 * Certain events within sync agent generate messages (such as "sync started",
 * "sync finished", "sync failed", "compose started", etc.)
 * Application can subscribe to listen to these messages and take actions
 * via message callbacks.  Note that the same messages will be logged
 * into syncagent log (bglog) in XML format.
 * For messages of type BG_MSG_TYPE_ERROR field id will contain error code,
 * field txt will contain error message, and field cause will optionally
 * point to descriptor of the cause of error (if cause is present)
 * @see bgmsg.h
 * @see bgMsgCallback
 * @see bgAddMsgCallback
 * @see bgErrorDesc
 */
typedef struct _bgMsg {
	/** Creation time in milliseconds since epoch */
	ose8B time;
	/**
	 * Message type as above
	 * @see Message types
	 */
	ose4B type;
	/**
	 * Message id
	 * @see bgmsg.h
	 */
	ose4B id;
	/** message text */
	const char *txt;
	/**
	 * Cause of error, or NULL
	 * Only applicable to messages of type BG_MSG_TYPE_ERROR if cause is
	 * present
	 */
	const bgErrorDesc *cause;
} bgMsg;

/** Callback context handle to store callback's state data */
typedef void *bgUserCtx;

/**
 * Message callback pointer type declaration.
 * @param ctx callback context handle
 * @param msg pointer to the message
 * @see bgMsg
 * @see bgAddMsgCallback
 * @see bgRemoveMsgCallback
 */
typedef void (* bgMsgCallback)(bgUserCtx ctx, const bgMsg *msg);

/**
 * Sync Agent parameters.  Parameters are stored in ose.ini configuration file
 * and are loaded at syncagent's startup.  If you change a parameter value,
 * you would need to restart syncagent for it to take effect.
 * Boolean parameters are treated as numeric and will have values
 * OSE_TRUE or OSE_FALSE.  The corresponding string values for them in
 * ose.ini can be TRUE|FALSE, YES|NO or ON|OFF.
 * @see bgSetNumParam
 * @see bgGetNumParam
 * @see bgSetStrParam
 * @see bgGetStrParam
 * @see bgGetStrParamNC
 */

/**
 * Boolean parameter, specifies whether syncagent should be disabled.
 * If syncagent is disabled, neither application nor system startup process
 * will be able to start it and BG_ERR_AGENT_DISABLED error will be returned
 * from bgControlAgent.  OSE_FALSE is the default.
 * ose.ini parameter: BGSYNC.DISABLE
 * @see bgmsg.h
 */
#define BG_PARAM_DISABLE_AGENT                  1

/**
 * Maximum number of log files to keep in the bglog directory.  The log is
 * circular, so that when the max number of files is reached and new log file
 * needs to be added, the oldest file will be removed. The default is 128 for
 * Win32 and Linux and 32 for Windows CE.
 * ose.ini parameter: BGSYNC.MAX_LOG_FILES
 */
#define BG_PARAM_MAX_LOG_FILE_COUNT             2

/**
 * Maximum log file size in bytes.  The default is 1MB on Win32 and Linux and
 * 128KB on Windows CE.
 * ose.ini parameter: BGSYNC.MAX_LOG_FILE_SIZE
 */
#define BG_PARAM_MAX_LOG_FILE_SIZE              3

/**
 * Boolean parameter to disable network manager functinality in syncagent.
 * This parameter is not yet supported.
 */
#define BG_PARAM_DISABLE_NET_MGR                4

/**
 * Boolean parameter to disable power manager functinality in syncagent.
 * This parameter is not yet supported.
 */
#define BG_PARAM_DISABLE_POWER_MGR              5

/**
 * Time internval in milliseconds for the network manager to wait before
 * evaluating network state in absence of network notifications.
 * Network manager will evaluate network when network notification is received
 * or the said internval expires.  In abscence of network notifications
 * the network will be evaluated periodically with the period equal to
 * the said interval.  The default is 10 mins (600000).
 * ose.ini parameter: BGSYNC.NET_WAIT_TIMEOUT
 */
#define BG_PARAM_NET_WAIT_TIMEOUT               6

/********************************************//**
 *  Sync Agent Control APIs
 ***********************************************/

#ifdef IN_BGSYNC
#define BG_API OSE_EXPORT
#else
#define BG_API OSE_IMPORT
#endif

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Open new BG session.  Note that in multithreaded environments a single
 * BG session is not supposed to be used concurrently from multiple threads.
 * Each thread should open its own BG session.
 * @param sess pointer to the session handle into which new session is
 * returned, cannot be NULL
 * @return 0 if successful
 * BG_ERR_INTERNAL if system error has occured
 * @see bgmsg.h
 */
BG_API bgError bgOpenSession(bgSess *sess);

/**
 * Close BG session and release resources held by it.
 * @param sess session handle
 * @return 0 if successful
 * BG_ERR_INVALID_SESSION if session handle was invalid
 */
BG_API bgError bgCloseSession(bgSess sess);

/**
 * Issue control command to sync agent.  Note that this call returns
 * immediately and does not wait for completion of command execution.
 * Use bgWaitForStatus to wait until syncagent reaches certain status.
 * @param sess session handle
 * @param ctrl control command code
 * @param opt options for given command
 * @return 0 if successful
 * BG_ERR_INVALID_SESSION if session handle was invalid
 * BG_ERR_INVALID_COMMAND if control command code was invalid
 * BG_ERR_CANNOT_ACCEPT_CTRL if syncagent is not able to execute given command
 * in its current state, for example trying to start syncagent when it's
 * stopping
 * other errors are also possible
 * @see bgmsg.h
 * @see Options for "start" command
 * @see Options for "stop" command
 * @see bgWaitForStatus
 */
BG_API bgError bgControlAgent(bgSess sess, int ctrl, int opt);

/**
 * Wait until syncagent reaches certain status.  Valid status codes to
 * wait for are BG_STATUS_STOPPED, BG_STATUS_RUNNING and BG_STATUS_PAUSED
 * @param sess session handle
 * @param statusCode status code to wait for
 * @param timeOut wait timeout in milliseconds, use -1 to wait forever
 * @return 0 if syncagent reached the specified status
 * BG_ERR_INVALID_SESSION if session handle was invalid
 * BG_ERR_WAIT_TIMEOUT if timeout has expired
 * BG_ERR_INVALID_WAIT_STATUS if status code is not one of the 3 above
 * BG_ERR_START, BG_ERR_STOP, BG_ERR_PAUSE or BG_ERR_RESUME if
 * previous control operation failed
 * other errors are also possible
 * @see bgmsg.h
 */
BG_API bgError bgWaitForStatus(bgSess sess, int statusCode, long timeOut);

/**
 * Get syncagent status.
 * @param sess session handle
 * @param s pointer to the agent status structure to return status into.
 * Cannot be NULL.
 * Note that the memory for pointer fields inside the structure is maintained
 * by syncagent and should not be freed by application
 * @return 0 if status retrieved successfully
 * BG_ERR_INVALID_SESSION if session handle was invalid
 * BG_ERR_INTERNAL if system error has occured
 * @see bgAgentStatus
 * @see bgmsg.h
 */
BG_API bgError bgGetAgentStatus(bgSess sess, bgAgentStatus *s);

/**
 * Get status per publication.
 * This API is currently not supported.
 */
BG_API bgError bgGetPubStatus(bgSess sess, const char *pub, bgPubStatus *s);

/**
 * Get sync status within syncagent.
 * @param sess session handle
 * @param s pointer to the sync status structure to return status into.
 * Cannot be NULL
 * Note that the memory for pointer fields inside the structure is maintained
 * by syncagent and should not be freed by application.
 * @return 0 if status retrieved successfully
 * BG_ERR_INVALID_SESSION if session handle was invalid
 * BG_ERR_INTERNAL if system error has occured
 * @see bgSyncStatus
 * @see bgmsg.h
 */
BG_API bgError bgGetSyncStatus(bgSess sess, bgSyncStatus *s);

/**
 * Add message callback to the session.  Callback function will be called
 * when syncagent messages are generated.
 * @param sess session handle
 * @param ctx callback's context handle
 * @param cb callback's function pointer
 * @return 0 if added successfully
 * BG_ERR_INVALID_SESSION if session handle was invalid
 * BG_ERR_INTERNAL if system error has occured
 * @see Sync Agent message and callback declarations
 */
BG_API bgError bgAddMsgCallback(bgSess sess, bgUserCtx ctx, bgMsgCallback cb);

/**
 * Remove message callback from the session.
 * Callback function will no longer be called once callback is removed.
 * @param sess session handle
 * @param ctx callback's context handle
 * @param cb callback's function pointer
 * @return 0 if removed successfully or given callback was not present
 * BG_ERR_INVALID_SESSION if session handle was invalid
 * BG_ERR_INTERNAL if system error has occured
 * @see Sync Agent message and callback declarations
 */
BG_API bgError bgRemoveMsgCallback(bgSess sess, bgUserCtx ctx,
	bgMsgCallback cb);

/**
 * Set numeric parameter.  The parameter will be saved into ose.ini
 * Note that new parameter value will take effect only after syncagent is
 * restarted.
 * @param sess session handle
 * @param param parameter code
 * @param val parameter value
 * @return 0 if set successfully
 * BG_ERR_INVALID_SESSION if session handle was invalid
 * BG_ERR_INVALID_PARAM if invalid parameter code specified
 * BG_ERR_INTERNAL if system error has occured
 * @see Sync Agent parameters
 * @see bgmsg.h
 */
BG_API bgError bgSetNumParam(bgSess sess, int param, long val);

/**
 * Get numeric parameter value.
 * @param sess session handle
 * @param param parameter code
 * @param val pointer to a variable to return value into, cannot be NULL
 * @return 0 if retrieved successfully
 * BG_ERR_INVALID_SESSION if session handle was invalid
 * BG_ERR_INVALID_PARAM if invalid parameter code specified
 * BG_ERR_INTERNAL if system error has occured
 * @see Sync Agent parameters
 * @see bgmsg.h
 */
BG_API bgError bgGetNumParam(bgSess sess, int param, long *val);

/**
 * Set string parameter.  The parameter will be saved into ose.ini
 * Note that new parameter value will take effect only after syncagent is
 * restarted.  Currently there are no string BG parameters.
 * @param sess session handle
 * @param param parameter code
 * @param val parameter value
 * @return 0 if set successfully
 * BG_ERR_INVALID_SESSION if session handle was invalid
 * BG_ERR_INVALID_PARAM if invalid parameter code specified
 * BG_ERR_INTERNAL if system error has occured
 * @see Sync Agent parameters
 * @see bgmsg.h
 */
BG_API bgError bgSetStrParam(bgSess sess, int param, const char *val);

/**
 * Get string parameter value. Currently there are no string BG parameters.
 * @param sess session handle
 * @param param parameter code
 * @param val buffer to retrieve the value into, can't be NULL
 * @param bufSize buffer size
 * @return 0 if retrieved successfully
 * BG_ERR_INVALID_SESSION if session handle was invalid
 * BG_ERR_INVALID_PARAM if invalid parameter code specified
 * OSE_ERR_INVALID_BUFFER if buffer was too small
 * BG_ERR_INTERNAL if system error has occured
 * @see Sync Agent parameters
 * @see oseGetStrOption
 * @see bgmsg.h
 */
BG_API bgError bgGetStrParam(bgSess sess, int param, char *val, int bufSize);

/**
 * Get string parameter value without copying.
 * Currently there are no string BG parameters.
 * @param sess session handle
 * @param param parameter code
 * @param val pointer to a character pointer into which return the value,
 * can't be NULL
 * @return 0 if retrieved successfully
 * BG_ERR_INVALID_SESSION if session handle was invalid
 * BG_ERR_INVALID_PARAM if invalid parameter code specified
 * BG_ERR_INTERNAL if system error has occured
 * @see Sync Agent parameters
 * @see oseGetStrOptionNC
 * @see bgmsg.h
 */
BG_API bgError bgGetStrParamNC(bgSess sess, int param, const char **val);

/**
 * Get extended error information from the last BG call.  This function is
 * totally analogous to oseGetLastError.
 * @param sess session handle
 * can be NULL if trying to retrieve error information from failed
 * bgOpenSession call
 * @param errDesc pointer to oseErrorDesc pointer into which oseErrorDesc
 * pointer will be returned.  Cannot be NULL. Note that the structures
 * referenced by this pointer are only valid until next BG call.
 * @return 0 if successful
 * BG_ERR_INVALID_SESSION if session handle was invalid
 * BG_ERR_INTERNAL if system error has occured
 * @see bgErrorDesc
 * @see oseGetLastError
 */
BG_API bgError bgGetLastError(bgSess sess, const bgErrorDesc **errDesc);

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif /* BGSYNC_H */
