/*
 *  OpenVPN -- An application to securely tunnel IP networks
 *             over a single UDP port, with support for TLS-based
 *             session authentication and key exchange,
 *             packet encryption, packet authentication, and
 *             packet compression.
 *
 *  Copyright (C) 2002 James Yonan <jim@yonan.net>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program (see the file COPYING included with this
 *  distribution); if not, write to the Free Software Foundation, Inc.,
 *  59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef SOCKET_H
#define SOCKET_H

#include "buffer.h"
#include "common.h"

#define ADDR_P(s) ((s)->sin_addr.s_addr)
#define ADDR(s) (s.sin_addr.s_addr)

struct udp_socket
{
  struct sockaddr_in local;
  struct sockaddr_in remote;
  bool remote_float;
  const char *ipchange_command;
  struct sockaddr_in *actual;
  int sd;			/* file descriptor for socket */
  bool set_outgoing_initial;
};

in_addr_t getaddr (const char *hostname);

void
udp_socket_init (struct udp_socket *sock,
		 const char *local_host,
		 const char *remote_host,
		 int local_port,
		 int remote_port,
		 bool bind_local,
		 bool remote_float,
		 struct sockaddr_in *actual, const char *ipchange_command);

void
udp_socket_set_outgoing_addr (const struct buffer *buf,
			      struct udp_socket *sock,
			      const struct sockaddr_in *addr);

void
udp_socket_incoming_addr (struct buffer *buf,
			  const struct udp_socket *sock,
			  const struct sockaddr_in *from_addr);


void
udp_socket_get_outgoing_addr (struct buffer *buf,
			      const struct udp_socket *sock,
			      struct sockaddr_in *addr);

void udp_socket_close (struct udp_socket *sock);

const char *
print_sockaddr_ex (const struct sockaddr_in *addr, bool do_port, const char* separator);

const char *
print_sockaddr (const struct sockaddr_in *addr);

#endif /* SOCKET_H */