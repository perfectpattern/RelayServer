# Original credit: https://github.com/jpetazzo/dockvpn
# Edited by AlexanderN, PerfectPattern

# Smallest base image
FROM alpine:latest

# Testing: pamtester
# Alex edit: Install and prepare openssh server
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    apk add --update --no-cache openvpn iptables bash easy-rsa openvpn-auth-pam google-authenticator pamtester openssh-server openssh-client && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/* /etc/ssh/

# Needed by scripts
ENV OPENVPN /etc/openvpn
ENV EASYRSA /usr/share/easy-rsa
ENV EASYRSA_PKI $OPENVPN/pki
ENV EASYRSA_VARS_FILE $OPENVPN/vars

# Prevents refused client connection because of an expired CRL
ENV EASYRSA_CRL_DAYS 3650

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
# Alex edit: expose ssh port as well
EXPOSE 1194/udp
EXPOSE 22/tcp

# Alex edit: run modified 'ovpn_run' script which has to be mounted manually
#CMD ["ovpn_run"]
CMD ["/root/scripts/relay_run.sh"]

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/
