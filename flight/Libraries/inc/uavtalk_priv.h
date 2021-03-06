/**
 ******************************************************************************
 * @addtogroup TauLabsCore Tau Labs Core components
 * @{
 * @addtogroup UAVTalk UAVTalk implementation
 * @{
 *
 * @file       uavtalk_priv.h
 * @author     The OpenPilot Team, http://www.openpilot.org Copyright (C) 2010.
 * @author     Tau Labs, http://taulabs.org, Copyright (C) 2013-2014
 * @brief      Private include file of the UAVTalk library
 * @see        The GNU Public License (GPL) Version 3
 *
 *****************************************************************************/
/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
 * for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, see <http://www.gnu.org/licenses/>
 */

#ifndef UAVTALK_PRIV_H
#define UAVTALK_PRIV_H

#include "uavobjectsinit.h"
#include "pios_semaphore.h"
#include "pios_mutex.h"

// Private types and constants

//! Minimal UAVTalk header without an instance field
typedef struct {
	uint8_t sync;
	uint8_t type;
	uint16_t size;
	uint32_t objId;
} uavtalk_min_header;
#define UAVTALK_MIN_HEADER_LENGTH       sizeof(uavtalk_min_header)

//! Full UAVTalk header with an instance field
typedef struct {
	uint8_t sync;
	uint8_t type;
	uint16_t size;
	uint32_t objId;
	uint16_t instId;
} uavtalk_max_header;
#define UAVTALK_MAX_HEADER_LENGTH       sizeof(uavtalk_max_header)

struct filereq_data {
	uint32_t offset;
	uint16_t flags;
} __attribute__((packed));

struct fileresp_data {
	uint32_t offset;
	uint8_t flags;
} __attribute__((packed));

typedef uint8_t uavtalk_checksum;
#define UAVTALK_CHECKSUM_LENGTH         sizeof(uavtalk_checksum)
#define UAVTALK_MAX_PAYLOAD_LENGTH      (UAVOBJECTS_LARGEST + 1)
#define UAVTALK_MIN_PACKET_LENGTH       UAVTALK_MAX_HEADER_LENGTH + UAVTALK_CHECKSUM_LENGTH
#define UAVTALK_MAX_PACKET_LENGTH       UAVTALK_MIN_PACKET_LENGTH + UAVTALK_MAX_PAYLOAD_LENGTH

//! State information for the UAVTalk parser
typedef struct {
	UAVObjHandle obj;
	uint8_t type;
	uint16_t packet_size;
	uint32_t objId;
	uint16_t instId;
	uint32_t length; /**< The length of the object payload (valid after UAVTALK_STATE_OBJID) */
	uint8_t instanceLength;
	uint8_t cs;
	int32_t rxCount;
	UAVTalkRxState state;
	uint16_t rxPacketLength;
} UAVTalkInputProcessor;

//! Information for the physical link
typedef struct {
	uint8_t canari;
	struct pios_recursive_mutex *lock;
	UAVTalkStats stats;
	UAVTalkInputProcessor iproc;
	uint8_t *rxBuffer;
	uint32_t txSize;
	uint8_t *txBuffer;

	UAVTalkOutputCb outCb;
	UAVTalkAckCb ackCb;
	UAVTalkFileCb fileCb;
	void *cbCtx;
} UAVTalkConnectionData;

#define UAVTALK_CANARI         0xCA
#define UAVTALK_WAITFOREVER     -1
#define UAVTALK_NOWAIT          0
#define UAVTALK_SYNC_VAL       0x3C
#define UAVTALK_TYPE_MASK      0x70
#define UAVTALK_TYPE_VER       0x20
#define UAVTALK_TIMESTAMPED    0x80
#define UAVTALK_TYPE_OBJ       (UAVTALK_TYPE_VER | 0x00)
#define UAVTALK_TYPE_OBJ_REQ   (UAVTALK_TYPE_VER | 0x01)
#define UAVTALK_TYPE_OBJ_ACK   (UAVTALK_TYPE_VER | 0x02)
#define UAVTALK_TYPE_ACK       (UAVTALK_TYPE_VER | 0x03)
#define UAVTALK_TYPE_NACK      (UAVTALK_TYPE_VER | 0x04)
#define UAVTALK_TYPE_FILEREQ   (UAVTALK_TYPE_VER | 0x08)
#define UAVTALK_TYPE_FILEDATA  (UAVTALK_TYPE_VER | 0x09)
#define UAVTALK_TYPE_OBJ_TS    (UAVTALK_TIMESTAMPED | UAVTALK_TYPE_OBJ)

#define UAVTALK_FILEDATA_EOF   0x01
#define UAVTALK_FILEDATA_LAST  0x02

//macros
#define CHECKCONHANDLE(handle,variable,failcommand) \
	variable = (UAVTalkConnectionData*) handle; \
	if (variable == NULL || variable->canari != UAVTALK_CANARI) { \
		failcommand; \
	}

#endif /* UAVTALK_PRIV_H */

/**
 * @}
 * @}
 */
