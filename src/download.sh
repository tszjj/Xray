get_latest_version() {
    case $1 in
    core)
        name=$is_core_name
        url="https://api.github.com/repos/${is_core_repo}/releases/latest?v=$RANDOM"
        ;;
    sh)
        name="$is_core_name 脚本"
        url="https://api.github.com/repos/$is_sh_repo/releases/latest?v=$RANDOM"
        ;;
    caddy)
        name="Caddy"
        url="https://api.github.com/repos/$is_caddy_repo/releases/latest?v=$RANDOM"
        ;;
    esac
    latest_ver=$(_wget -qO- $url | grep tag_name | grep -E -o 'v([0-9.]+)')
    # 本分支未发布 release(例如 fork 未启用 Actions) 时, 直接从分支源码读取脚本版本号
    [[ ! $latest_ver && $1 == 'sh' ]] && {
        latest_ver=$(_wget -qO- "https://raw.githubusercontent.com/${is_sh_repo}/main/${is_core}.sh" | grep -E -o 'ver=v[0-9.]+' | sed 's/ver=//')
        [[ $latest_ver ]] && is_sh_src_zip=1
    }
    [[ ! $latest_ver ]] && {
        err "获取 ${name} 最新版本失败."
    }
    unset name url
}
download() {
    latest_ver=$2
    [[ ! $latest_ver && $1 != 'dat' ]] && get_latest_version $1
    # tmp dir
    tmpdir=$(mktemp -u)
    [[ ! $tmpdir ]] && {
        tmpdir=/tmp/tmp-$RANDOM
    }
    mkdir -p $tmpdir
    case $1 in
    core)
        name=$is_core_name
        tmpfile=$tmpdir/$is_core.zip
        link="https://github.com/${is_core_repo}/releases/download/${latest_ver}/${is_core}-linux-${is_core_arch}.zip"
        download_file
        unzip -qo $tmpfile -d $is_core_dir/bin
        chmod +x $is_core_bin
        ;;
    sh)
        name="$is_core_name 脚本"
        tmpfile=$tmpdir/sh.zip
        if [[ $is_sh_src_zip ]]; then
            # 无 release 时使用分支源码包
            link="https://github.com/${is_sh_repo}/archive/refs/heads/main.zip"
        else
            link="https://github.com/${is_sh_repo}/releases/download/${latest_ver}/code.zip"
        fi
        download_file
        if [[ $is_sh_src_zip ]]; then
            mkdir -p $tmpdir/sh_src
            unzip -qo $tmpfile -d $tmpdir/sh_src
            cp -rf $tmpdir/sh_src/*/* $is_sh_dir/
        else
            unzip -qo $tmpfile -d $is_sh_dir
        fi
        chmod +x $is_sh_bin
        ;;
    dat)
        name="geoip.dat"
        tmpfile=$tmpdir/geoip.dat
        link="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
        download_file
        name="geosite.dat"
        tmpfile=$tmpdir/geosite.dat
        link="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
        download_file
        cp -f $tmpdir/*.dat $is_core_dir/bin/
        ;;
    caddy)
        name="Caddy"
        tmpfile=$tmpdir/caddy.tar.gz
        # https://github.com/caddyserver/caddy/releases/download/v2.6.4/caddy_2.6.4_linux_amd64.tar.gz
        link="https://github.com/${is_caddy_repo}/releases/download/${latest_ver}/caddy_${latest_ver:1}_linux_${caddy_arch}.tar.gz"
        download_file
        [[ ! $(type -P tar) ]] && {
            rm -rf $tmpdir
            err "请安装 tar"
        }
        tar zxf $tmpfile -C $tmpdir
        cp -f $tmpdir/caddy $is_caddy_bin
        chmod +x $is_caddy_bin
        ;;
    esac
    rm -rf $tmpdir
    unset latest_ver
}
download_file() {
    if ! _wget -t 5 -c $link -O $tmpfile; then
        rm -rf $tmpdir
        err "\n下载 ${name} 失败.\n"
    fi
}
