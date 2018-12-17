# Pode

[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/Badgerati/Pode/master/LICENSE.txt)
[![Documentation](https://img.shields.io/badge/docs-latest-blue.svg)](https://badgerati.github.io/Pode)
[![AppVeyor](https://img.shields.io/appveyor/ci/Badgerati/Pode/develop.svg?label=AppVeyor)](https://ci.appveyor.com/project/Badgerati/pode/branch/develop)
[![Travis CI](https://img.shields.io/travis/Badgerati/Pode/develop.svg?label=Travis%20CI)](https://travis-ci.org/Badgerati/Pode)
[![Gitter](https://badges.gitter.im/Badgerati/Pode.svg)](https://gitter.im/Badgerati/Pode?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

[![Chocolatey](https://img.shields.io/chocolatey/dt/pode.svg?label=Chocolatey&colorB=a1301c)](https://chocolatey.org/packages/pode)
[![PowerShell](https://img.shields.io/powershellgallery/dt/pode.svg?label=PowerShell&colorB=085298)](https://www.powershellgallery.com/packages/Pode)
[![Docker](https://img.shields.io/docker/pulls/badgerati/pode.svg?label=Docker)](https://hub.docker.com/r/badgerati/pode/)

Pode is a Cross-Platform PowerShell framework to create web servers that host [REST APIs](https://badgerati.github.io/Pode/Tutorials/Routes/Overview/), [Web Pages](https://badgerati.github.io/Pode/Tutorials/Routes/WebPages/), and [SMTP/TCP](https://badgerati.github.io/Pode/Tutorials/SmtpServer/) Servers. It also allows you to render dynamic files using [Pode](https://badgerati.github.io/Pode/Tutorials/ViewEngines/Pode/) files, which is effectively embedded PowerShell, or other [Third-Party](https://badgerati.github.io/Pode/Tutorials/ViewEngines/ThirdParty/) template engines.

## Documentation

All documentation and tutorials for Pode can be [found here](https://badgerati.github.io/Pode) - this documentation will be for the latest release.

To see the docs for other releases, branches or tags, you can host the documentation locally. To do so you'll need to have the [`Invoke-Build`](https://github.com/nightroman/Invoke-Build) module installed; then:

```powershell
Invoke-Build Docs
```

Then navigate to `http://127.0.0.1:8000` in your browser.

## Features

* Cross-platform via PowerShell Core (with support for PS4.0+)
* Listen on a single or multiple IP address/hostnames
* Support for HTTP, HTTPS, TCP and SMTP
* Host REST APIs, Web Pages, and Static Content
* Multi-thread support for incoming requests
* Inbuilt template engine, with support for third-parties
* Async timers for short-running repeatable processes
* Async scheduled tasks using cron expressions for short/long-running processes
* Supports logging to CLI, Files, and custom loggers to other services like LogStash, etc.
* Cross-state variable access across multiple runspaces
* Optional file monitoring to trigger internal server restart on file changes
* Ability to allow/deny requests from certain IP addresses and subnets
* Basic rate limiting for IP addresses and subnets
* Middleware and sessions on web servers
* Authentication on requests, which can either be sessionless or session persistent
* (Windows) Generate/bind self-signed certificates, and signed certificates
* (Windows) Open the hosted server as a desktop application

## Build Your First App

Below is a quick example of using Pode to create a single REST API endpoint to return a JSON response. It will listen on a port, create the route, and respond with JSON when `http://localhost:8080/ping` is hit:

```powershell
Server {
    listen localhost:8080 http

    route get '/ping' {
        json @{ 'value' = 'pong' }
    }
}
```

See [here](https://badgerati.github.io/Pode/Getting-Started/FirstApp) for building your first app!

## Install

You can install Pode from either Chocolatey, the PowerShell Gallery, or Docker:

```powershell
# chocolatey
choco install pode

# powershell gallery
Install-Module -Name Pode

# docker
docker pull badgerati/pode
```
