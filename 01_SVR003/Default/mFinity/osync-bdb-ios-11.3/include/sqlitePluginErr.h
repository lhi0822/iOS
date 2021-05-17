/**
 * @file sqlitePluginErr.h Sqlite/BDB Plugin error codes and error messages.
 */

/**
 * Sqlite/BDB plugin uses parametrized error messages, hence you will see
 * placeholders like %c, %d,%ld, %x, %s embedded inside error messages.
 * They stand for values placed in error message when error occurs.
 * They are analogous to printf formatting specifications.
 */

#ifndef SQLITE_PLUGIN_ERROR_H
#define SQLITE_PLUGIN_ERROR_H

#define SQLITE_ERR_SQLITE					-13000	/* Sqlite database error (see the cause) */

#define SQLITE_ERR_INVALID_DATA				-13001	/* Invalid snapshot data received */

#define SQLITE_ERR_COLUMN_DEF				-13002	/* Invalid column definition received */

#define SQLITE_ERR_PK_DEF					-13003	/* Invalid primary key definition received */

#define SQLITE_ERR_STATE_COLUMN				-13004	/* Invalid data in STATE column */

#define SQLITE_ERR_LARGE_DATA				-13005	/* Large column data (> 64K) is not supported */

#define SQLITE_ERR_SNAP_NOT_FOUND			-13006	/* Could not find snapshot with id %ld */

#define SQLITE_ERR_BLOBS_IN_PK				-13007	/* Snapshot \"%s\", column \"%s\": blob columns are not allowed in primary key */

#define SQLITE_ERR_SNAP_READONLY			-13008	/* Cannot send changes for read-only snapshot \"%s\" */

#define SQLITE_ERR_SNAP_EXISTS				-13009	/* Snapshot with id %ld already exists */

#define SQLITE_ERR_INVALID_IDX_INFO			-13010	/* Invalid index info received for index \"%s\" */

#define SQLITE_ERR_SCRIPT					-13011	/* An error has occured during the execution of script \"%s\" */

#define SQLITE_ERR_INVALID_ARG				-13012	/* Invalid argument(s) is passed to the function */

#define SQLITE_ERR_INTERNAL					-13013  /* Internal error has occured (the cause may have more info) */

#define SQLITE_ERR_INVALID_SNAP_ID          -13014  /* Invalid snapshot id %ld for snapshot \"%s\" */

#define SQLITE_ERR_SQLITE_NEED_RECOVER      -13015  /* Sqlite database error, recovery is needed (see the cause) */

#define SQLITE_ERR_DUPLICATE_META_SNAP      -13020  /* Duplicate meta snapshot: \"%s\" */

#define SQLITE_ERR_SNAP_READONLY_NO_PK      -13021  /* Cannot update or delete from read-only snapshot \"%s\" with no primary key */

#endif //SQLITE_PLUGIN_ERROR_H
