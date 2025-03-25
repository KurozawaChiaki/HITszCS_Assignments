#include "ethernet.h"
#include "utils.h"
#include "driver.h"
#include "arp.h"
#include "ip.h"
/**
 * @brief 处理一个收到的数据包
 * 
 * @param buf 要处理的数据包
 */
void ethernet_in(buf_t *buf)
{
	// 如果数据包的长度比MAC头部的大小还小，则说明无效
    if (buf->len < sizeof(ether_hdr_t))
        return;

	// 将MAC头部的内容解析出来
    ether_hdr_t *hdr = (ether_hdr_t*)buf->data;
    uint8_t *src = hdr->src;
    uint16_t protocol = swap16(hdr->protocol16);

	// 移除MAC头部，并将相关信息移入下一步
    buf_remove_header(buf, sizeof(ether_hdr_t));
    net_in(buf, protocol, src);
}
/**
 * @brief 处理一个要发送的数据包
 * 
 * @param buf 要处理的数据包
 * @param mac 目标MAC地址
 * @param protocol 上层协议
 */
void ethernet_out(buf_t *buf, const uint8_t *mac, net_protocol_t protocol)
{
	// 如果数据包长度不足46，则通过buf_add_padding()进行填充
    if (buf->len < 46) {
        buf_add_padding(buf, 46 - buf->len);
    }

	// 通过buf_add_header()为数据包分配新空间用于写入报头
    buf_add_header(buf, sizeof(ether_hdr_t));
    ether_hdr_t *hdr = (ether_hdr_t*)buf->data;

	// 填充内容
    memcpy(hdr->dst, mac, NET_MAC_LEN);
    memcpy(hdr->src, net_if_mac, NET_MAC_LEN);

    hdr->protocol16 = swap16(protocol);
    driver_send(buf);
}
/**
 * @brief 初始化以太网协议
 * 
 */
void ethernet_init()
{
    buf_init(&rxbuf, ETHERNET_MAX_TRANSPORT_UNIT + sizeof(ether_hdr_t));
}

/**
 * @brief 一次以太网轮询
 * 
 */
void ethernet_poll()
{
    if (driver_recv(&rxbuf) > 0)
        ethernet_in(&rxbuf);
}
