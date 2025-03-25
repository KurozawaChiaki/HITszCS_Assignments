#include "net.h"
#include "ip.h"
#include "ethernet.h"
#include "arp.h"
#include "icmp.h"

int send_id = 0;

/**
 * @brief 处理一个收到的数据包
 * 
 * @param buf 要处理的数据包
 * @param src_mac 源mac地址
 */
void ip_in(buf_t *buf, uint8_t *src_mac)
{
	// 如果数据包长度小于IP报头长度，则丢弃
    if (buf->len < sizeof(ip_hdr_t))
		return;

	// 报头检测
	ip_hdr_t *head = (ip_hdr_t*)buf->data;
	// 1. IP头部版本号
	if (head->version != IP_VERSION_4)
		return;
	// 2. 总长度字段是否小于或等于收到的包的长度
	if (swap16(head->total_len16) > buf->len)
		return;

	// 校验和检测
	uint16_t check_sum = head->hdr_checksum16;
	head->hdr_checksum16 = 0;
	uint16_t temp = checksum16((uint16_t*)buf->data, sizeof(ip_hdr_t));
	if (swap16(check_sum) != temp)
		return;
	head->hdr_checksum16 = check_sum;

	// 对比目的IP地址是否为本机的IP地址
	if (memcmp(head->dst_ip, net_if_ip, NET_IP_LEN) != 0)
		return;

	// 去除填充字段
	if (swap16(head->total_len16) < buf->len)
		buf_remove_padding(buf, buf->len - swap16(head->total_len16));

	// 如果协议类型不能识别
	if(!(head->protocol == NET_PROTOCOL_UDP || head->protocol == NET_PROTOCOL_ICMP))
		icmp_unreachable(buf, head->src_ip, ICMP_CODE_PROTOCOL_UNREACH);

	// 去除IP报头，向上传递
	buf_remove_header(buf, sizeof(ip_hdr_t));
	net_in(buf, head->protocol, head->src_ip);
}

/**
 * @brief 处理一个要发送的ip分片
 * 
 * @param buf 要发送的分片
 * @param ip 目标ip地址
 * @param protocol 上层协议
 * @param id 数据包id
 * @param offset 分片offset，必须被8整除
 * @param mf 分片mf标志，是否有下一个分片
 */
void ip_fragment_out(buf_t *buf, uint8_t *ip, net_protocol_t protocol, int id, uint16_t offset, int mf)
{
	// 分配IP报头空间
	buf_add_header(buf, sizeof(ip_hdr_t));

	ip_hdr_t *head = (ip_hdr_t*)buf->data;
	// 填写报头信息
	head->hdr_len = sizeof(ip_hdr_t) / IP_HDR_LEN_PER_BYTE;
	head->version = IP_VERSION_4;
	head->tos = 0;
	head->total_len16 = swap16(buf->len);
	head->id16 = swap16(id);
	uint16_t flags_fragment = (offset & 0x1FFFFFFF);
	if(mf == 1)
		flags_fragment |= IP_MORE_FRAGMENT;
	head->flags_fragment16 = swap16(flags_fragment);
	head->ttl = 64;
	head->protocol = protocol;
	memcpy(head->src_ip, net_if_ip, NET_IP_LEN);
	memcpy(head->dst_ip, ip, NET_IP_LEN);

	// 计算校验和
	head->hdr_checksum16 = 0;
	head->hdr_checksum16 = swap16(checksum16((uint16_t *)buf->data, sizeof(ip_hdr_t)));

	// 发送
	arp_out(buf, ip);
}

/**
 * @brief 处理一个要发送的ip数据包
 * 
 * @param buf 要处理的包
 * @param ip 目标ip地址
 * @param protocol 上层协议
 */
void ip_out(buf_t *buf, uint8_t *ip, net_protocol_t protocol)
{
    size_t maximum = 1500 - sizeof(ip_hdr_t);

	int i;
	buf_t ip_buf;
	for(i = 0; (i + 1) * maximum < buf->len; i++)
	{
		buf_init(&ip_buf, maximum);
		memcpy(ip_buf.data, buf->data + i * maximum, maximum);
		ip_fragment_out(&ip_buf, ip, protocol, send_id, i * (maximum >> 3), 1);
	}
	if(buf->len - i * maximum <= 0)  printf("ERROR");
	buf_init(&ip_buf, buf->len - i * maximum);
	memcpy(ip_buf.data, buf->data + i * maximum, buf->len - i * maximum);
	ip_fragment_out(&ip_buf, ip, protocol, send_id, i * (maximum >> 3), 0);
	send_id++;
}

/**
 * @brief 初始化ip协议
 * 
 */
void ip_init()
{
    net_add_protocol(NET_PROTOCOL_IP, ip_in);
}