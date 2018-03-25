FROM eclipse/stack-base:ubuntu

# Install dependencies
RUN sudo apt-get update \
	&& sudo apt-get install -y \
		g++ \
		make \
		libreadline-dev \
		haskell-platform \
	&& sudo apt-get clean

WORKDIR /home/user

# Install cryptol
RUN curl -LO https://github.com/GaloisInc/cryptol/releases/download/2.5.0/cryptol-2.5.0-Ubuntu1404-64.tar.gz \
	&& tar -xzf cryptol-2.5.0-Ubuntu1404-64.tar.gz \
	&& sudo ln -s /home/user/cryptol-2.5.0-Ubuntu14.04-64/bin/cryptol /usr/local/bin/cryptol 

# Install related packages (Eg: z3, abc provers)
RUN curl -LO https://github.com/Z3Prover/z3/releases/download/z3-4.6.0/z3-4.6.0-x64-ubuntu-16.04.zip \
	&& unzip z3-4.6.0-x64-ubuntu-16.04.zip \
	&& sudo ln -s /home/user/z3-4.6.0-x64-ubuntu-16.04/bin/z3 /usr/local/bin/z3
RUN curl -LO https://bitbucket.org/alanmi/abc/get/77d52065fd97.zip \
	&& unzip 77d52065fd97.zip \
	&& rm 77d52065fd97.zip \
	&& cd alanmi-abc-77d52065fd97\
	&& make \
	&& sudo ln -s /home/user/alanmi-abc-77d52065fd97/abc /usr/local/bin/abc

WORKDIR /projects
