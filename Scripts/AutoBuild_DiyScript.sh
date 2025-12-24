#!/bin/bash
# AutoBuild Module by Hyy2001 <https://github.com/Hyy2001X/AutoBuild-Actions-BETA>
# AutoBuild DiyScript

Firmware_Diy_Core() {
    # 请在该函数内按需修改变量设置, 使用 case 语句控制不同预设变量的设置
    
    Author=AUTO
    Author_URL=AUTO
    Default_Flag=AUTO
    Default_IP="192.168.1.1"
    Default_Title="Powered by AutoBuild-Actions"
    Short_Fw_Date=true
    x86_Full_Images=false
    Fw_MFormat=AUTO
    Regex_Skip="packages|buildinfo|sha256sums|manifest|kernel|rootfs|factory|itb|profile|ext4|json"
    AutoBuild_Features=true
    AutoBuild_Features_Patch=false
    AutoBuild_Features_Kconfig=false
}

Firmware_Diy() {
    # 请在该函数内定制固件
    
    case "${OP_AUTHOR}/${OP_REPO}:${OP_BRANCH}" in
    webappstars/myde:master)
        # 基础 Feed 设置
        sed -i '1i src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
        sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default

        # 硬件特定配置
        case "${TARGET_BOARD}" in
        ramips)
            # 可以在此处添加 ramips 的特殊指令
            :
        ;;
        esac

        case "${CONFIG_FILE}" in
        d-team_newifi-d2-Clash | xiaoyu_xy-c5-Clash)
            ClashDL mipsle-hardfloat tun
        ;;
        esac
            
        case "${TARGET_PROFILE}" in
        d-team_newifi-d2)
            Copy ${CustomFiles}/${TARGET_PROFILE}_system ${BASE_FILES}/etc/config system
        ;;
        xiaomi_redmi-router-ax6s)
            AddPackage passwall-depends xiaorouji openwrt-passwall-packages main
            AddPackage passwall-luci xiaorouji openwrt-passwall main
        ;;
        esac
    ;; # 闭合 webappstars/myde:master 分支

    immortalwrt/immortalwrt*)
        case "${TARGET_PROFILE}" in
        x86_64)
            sed -i -- 's:/bin/ash:'/bin/bash':g' ${BASE_FILES}/etc/passwd
            case "${CONFIG_FILE}" in
            x86_64)
                AddPackage qosmate hudra0 qosmate main
                AddPackage qosmate hudra0 luci-app-qosmate main
                AddPackage passwall xiaorouji openwrt-passwall main
                AddPackage passwall xiaorouji openwrt-passwall-packages main
                rm -r ${FEEDS_LUCI}/luci-app-passwall
                Copy ${CustomFiles}/speedtest ${BASE_FILES}/usr/bin
                chmod +x ${BASE_FILES}/usr/bin/speedtest
            ;;
            esac
        ;;
        esac
    ;;

    padavanonly/immortalwrtARM*)
        case "${TARGET_PROFILE}" in
        xiaomi_redmi-router-ax6s)
            :
        ;;
        esac
    ;;

    hanwckf/immortalwrt-mt798x*)
        case "${TARGET_PROFILE}" in
        cmcc_rax3000m | jcg_q30)
            AddPackage passwall xiaorouji openwrt-passwall main
            AddPackage passwall xiaorouji openwrt-passwall-packages main
            patch < ${CustomFiles}/mt7981/0001-Add-iptables-socket.patch -p1 -d ${WORK}
            rm -rf ${WORK}/feeds/luci/applications/luci-app-passwall
            rm -rf ${WORK}/feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
            rm -rf ${WORK}/package/network/services/dnsmasq
            Copy ${CustomFiles}/dnsmasq ${WORK}/package/network/services
            find ${WORK}/package/ -name "*mosdns*" | xargs rm -rf
            AddPackage other sbwml luci-app-mosdns v5
        ;;
        esac
    ;;
    esac

    # 全局特定架构处理 (针对 x86_64)
    case "${TARGET_PROFILE}" in
    x86_64)
        Copy ${CustomFiles}/Depends/cpuset ${BASE_FILES}/bin
        ReleaseDL https://api.github.com/repos/nxtrace/NTrace-core/releases/latest nexttrace_linux_amd64 ${BASE_FILES}/bin nexttrace

        hysteria_version="2.6.1"
        wstunnel_version="9.2.3"
        wget --quiet --no-check-certificate -P /tmp \
            https://github.com/apernet/hysteria/releases/download/app%2Fv${hysteria_version}/hysteria-linux-amd64
        wget --quiet --no-check-certificate -P /tmp \
            https://github.com/erebe/wstunnel/releases/download/v${wstunnel_version}/wstunnel_${wstunnel_version}_linux_amd64.tar.gz
        tar -xvzf /tmp/wstunnel_${wstunnel_version}_linux_amd64.tar.gz -C /tmp
        Copy /tmp/wstunnel ${BASE_FILES}/usr/bin
        Copy /tmp/hysteria-linux-amd64 ${BASE_FILES}/usr/bin hysteria
        chmod +x ${BASE_FILES}/usr/bin/hysteria ${BASE_FILES}/usr/bin/wstunnel
    ;;
    esac
}
