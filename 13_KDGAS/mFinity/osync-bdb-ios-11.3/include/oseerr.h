/**
 * @file ose.h OSE error codes and error messages.
 */

/**
 * OSE uses parametrized error messages, hence you will see placeholders like
 * %c, %d,%ld, %x, %s embedded inside error messages.  They stand for values
 * placed in error message when error occurs.  They are analogous to printf
 * formatting specifications.
 */

#define OSE_ERR_SYNC_CANCELED				-12000	/* Sync was canceled */

#define OSE_ERR_UNEXP_OPCODE				-12001	/* Expecting opcode '%c', received '%c' */

#define OSE_ERR_DB_NOT_FOUND				-12002	/* Could not find database \"%s\" */

#define OSE_ERR_USER_NOT_SPECIFIED			-12003	/* User is not specified and last user was not recorded */

#define OSE_ERR_PWD_NOT_SPECIFIED			-12004	/* Password is not specified and was not saved for user \"%s\" */

#define OSE_ERR_INVALID_DML_TYPE			-12005	/* Got invalid record DML type %d from the plugin */

#define OSE_ERR_INVALID_OPCODE				-12006	/* Received invalid opcode %d */

#define OSE_ERR_OPCODE_LEN_OVERRUN			-12007	/* Cannot read %ld bytes for opcode '%c', only %ld bytes remain */

#define OSE_ERR_OPCODE_LEN_UNDERRUN			-12008	/* %ld bytes for opcode '%c' have not been read */

#define OSE_ERR_MISSING_PLUGIN_API			-12009	/* Plugin API \"%s\" not found in library \"%s\" */

#define OSE_ERR_INVALID_PLUGIN_FLAGS		-12010	/* Plugin returned invalid flags '%x' */

#define OSE_ERR_PLUGIN_ERROR				-12011	/* Plugin returned error %ld: %s */

#define OSE_ERR_INVALID_SYNC_DIR			-12012	/* Invalid sync direction specified: %d */

#define OSE_ERR_INVALID_INT_OPT				-12013	/* Invalid integer option specified: %d */

#define OSE_ERR_INVALID_STR_OPT				-12014	/* Invalid string option specified: %d */

#define OSE_ERR_UNINIT_USER_TRANSPORT		-12015	/* Transport type is user but user transport is not initialized */

#define OSE_ERR_INVALID_TRANSPORT_TYPE		-12016	/* Invalid transport type specified: %d */

#define OSE_ERR_PLUGIN_NOT_FOUND			-12017	/* Could not find plugin with id %ld */

#define OSE_ERR_UNEXP_LOB_DATA				-12018	/* Retrieved record with LOB(s) for a plugin not supporting LOBs */

#define OSE_ERR_PUB_NOT_FOUND				-12019	/* Could not find publication \"%s\" */

#define OSE_ERR_SNAP_NAME_NOT_FOUND			-12020	/* Could not find snapshot \"%s\" in publication \"%s\" */

#define OSE_ERR_SNAP_ID_NOT_FOUND			-12021	/* Could not find snapshot with id %ld */

#define OSE_ERR_TRANS_NOT_FOUND				-12022	/* Could not find transaction with id %ld */

#define	OSE_ERR_SNAP_ID_EXISTS				-12023	/* Snapshot with id %ld already exists */

#define OSE_ERR_OPCODE_OUT_OF_SEQ			-12024	/* Received opcode '%c' out of sequence */

#define OSE_ERR_INVALID_ENCR_VER			-12025	/* Invalid encryption transport version specified: %d */

#define OSE_ERR_INVALID_SESS				-12026	/* Invalid session handle was provided */

#define OSE_ERR_INVALID_HANDLE				-12027	/* Invalid handle was provided */

#define OSE_ERR_INTERNAL					-12028	/* Internal error has occurred */

#define OSE_ERR_UNEXP_TERM_OPCODE			-12029	/* Unexpected termination opcode encountered during receive */

#define OSE_ERR_ENCR_ID_MISMATCH			-12030	/* Sent encryption id (%lu,%lu+1) does not matched received (%lu,%lu) */

#define OSE_ERR_UNRECOGNIZED_DATA			-12031	/* Received unrecognized data */

#define	OSE_ERR_UNCOMPR_DATA				-12032	/* Received erroneous uncompressed data */

#define OSE_ERR_INVALID_HTTP_URL			-12033	/* Invalid HTTP URL specified: \"%s\" */

#define OSE_ERR_INVALID_ENCRYPTION_TYPE		-12034	/* Invalid encryption type specified: %d */

#define OSE_ERR_HTTP_RESPONSE				-12035	/* Unsuccessful http response: \"%s\" */

#define OSE_ERR_CONFIG_LOAD					-12036	/* Error loading sync configuration (see the cause) */

#define OSE_ERR_CONFIG_SAVE					-12037	/* Error saving sync configuration (see the cause) */

#define OSE_ERR_SERVER_ERROR				-12038	/* Server error has occurred (see the cause) */

#define OSE_ERR_INTERNAL_ERROR				-12039	/* Internal error has occurred (see the cause) */

#define OSE_ERR_MISSING_DEFAULT_DB			-12040	/* Need default database in order to create snapshot \"%s\" */

#define OSE_ERR_HTTP_TRANSPORT_ERROR		-12041	/* Http Transport error has occurred (see the cause) */

#define OSE_ERR_USER_TRANSPORT_ERROR		-12042	/* User Transport error has occurred (see the cause) */

#define OSE_ERR_PUB_ID_NOT_FOUND			-12043	/* Could not find publication id %lu */

#define OSE_ERR_PLUGIN_LIB_LOAD		        -12044	/* Failed to load plugin library \"%s\" (see the cause) */

#define OSE_ERR_NOT_SUPPORTED				-12045	/* API or feature \"%s\" is not supported */

#define OSE_ERR_INVALID_BUFFER				-12046	/* Invalid buffer pointer or buffer length specified */

#define OSE_ERR_INVALID_PRIO				-12047	/* Invalid priority specified: %d */

#define OSE_ERR_RESUME_SEND					-12048  /* Failed to resume sending data */

#define OSE_ERR_RESUME_RECEIVE				-12049	/* Failed to resume receiving data */

#define OSE_ERR_INVALID_TR_DIR				-12050	/* Invalid transport direction specified: %d */

#define OSE_ERR_INVALID_FILE_URL			-12051	/* Invalid file url specified: \"%s\" */

#define OSE_ERR_NO_SEND_RECEIVE				-12052	/* Only SEND or RECEIVE directions are allowed for a one-way transport */

#define OSE_ERR_SESS_KEY_NOT_FOUND			-12053	/* Could not find session key while doing receive on a one-way transport */

#define OSE_ERR_DB_KEY_NOT_FOUND			-12054	/* Could not find database key for encrypted database \"%s\" */

#define OSE_ERR_CANNOT_SYNC_BG              -12055  /* Background sync is not possible at this time (please complete first sync or setup sync) */

#define OSE_ERR_MISSING_PUBLIC_KEY          -12056  /* Server's public key is missing and could not be obtained */

#define OSE_MSG_EXPORT_URL                  15000   /* N/A (Export Mode) */

#define OSE_MSG_EXPORT_FINISHED             15001   /* The database data has been exported.  Please proceed with client upgrade. */

#define OSE_MSG_SETUP_FINISHED              15002   /* The client databases have been set up.  Please sync again to import the data from the binary file generated during the export stage.  If you would like to specify custom location for this file, please use the File sync options. */

#define OSE_MSG_IMPORT_FINISHED             15003   /* The client data has been imported.  This concludes the client upgrade. */
