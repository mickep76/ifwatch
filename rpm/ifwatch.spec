%define sources %{_topdir}/SOURCES

BuildRoot: %{_topdir}/BUILDROOT
Source: None
#%{_topdir}/SOURCES
Summary: %{name}
Name: ifwatch
Version: %{_ver}
Release: %{_rel}
License: Apache License, Version 2.0
Group: System
AutoReqProv: no
BuildRequires: go git rpm-build

%description
Listen to netlink events on network interfaces and publish it to etcd or Kafka

%prep
mkdir -p go/{pkg,bin} go/src/%{_src}
cp -r %{sources}/* go/src/%{_src}

%build
GOPATH=$PWD/go
PATH=$GOPATH/bin:$PATH
export GOPATH PATH

# Install Glide
go get github.com/Masterminds/glide/...

# Download packages
cd $GOPATH/src/%{_src} && ls -la && glide up

# Compile
cd $GOPATH/src/%{_src} && go build .

%install
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/etc/systemd/system
mkdir -p %{buildroot}/etc/{init.d,sysconfig}

cp go/src/%{_src}/ifwatch %{buildroot}/usr/bin
cp %{sources}/rpm/%{name}.service %{buildroot}/etc/systemd/system/%{name}.service
cp %{sources}/rpm/%{name}.initd %{buildroot}/etc/init.d/%{name}
cp %{sources}/rpm/%{name}.sysconfig %{buildroot}/etc/sysconfig/%{name}

%post
which systemctl &>/dev/null && systemctl daemon-reload

%preun
# Disable and stop on uninstall
if [ "${1}" == "0" ]; then
  if which systemctl &>/dev/null; then
    systemctl stop %{name}
    systemctl disable %{name}
  else
    service %{name} stop
    chkconfig %{name} off
  fi
fi

%postun
# Restart on upgrade
if [ "${1}" == "1" ]; then
  if which systemctl &>/dev/null; then
    systemctl condrestart %{name}
  else
    service %{name} condrestart
  fi
fi

%files
%defattr(-,root,root)
/usr/bin/%{name}
/etc/systemd/system/%{name}.service
%attr(755,-,-) /etc/init.d/%{name}
%config(noreplace) /etc/sysconfig/%{name}
