FROM centos:centos7
  
# Install Go and RPM Build
RUN yum install -y go git rpm-build glide && yum clean all

# Setup Go
#ENV GOPATH /go
#ENV PATH $GOPATH:$PATH
#RUN mkdir -p $GOPATH/{src,pkg,bin}

# Copy source
#ARG SRC
#RUN mkdir -p $GOPATH/src/$SRC
#COPY . $GOPATH/src/$SRC

# Install Glide
#RUN go get github.com/Masterminds/glide/...

# Download packages
#RUN cd $GOPATH/src/$SRC && $GOPATH/bin/glide up
#RUN cd $GOPATH/src/$SRC && go build .

# Build RPM
RUN mkdir -p /root/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
COPY rpm/ifwatch.spec /root/rpmbuild/SPECS/
COPY . /root/rpmbuild/SOURCES/

ARG SRC
ARG VER
ARG REL

RUN rpmbuild -bb \
      --target="x86_64" \
      --define "_topdir /root/rpmbuild" \
      --define "_src ${SRC}" \
      --define "_ver ${VER}" \
      --define "_rel ${REL}" \
      /root/rpmbuild/SPECS/ifwatch.spec
