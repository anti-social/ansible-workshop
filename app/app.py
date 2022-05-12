import os

from aiohttp import web

import asyncio

import sdnotify


async def hello(request):
    return web.Response(
        text=f"Hello, world from {os.environ.get('NAME', '???')}\n"
    )


# async def notify_ready(app):
#     notify_socket = os.environ.get('NOTIFY_SOCKET')
#     if notify_socket:
#         sdnotify.SystemdNotifier().notify('READY=1')


def notify_ready():
    notify_socket = os.environ.get('NOTIFY_SOCKET')
    if notify_socket:
        sdnotify.SystemdNotifier().notify('READY=1')


async def run(app):
    runner = web.AppRunner(app, handle_signals=True)
    await runner.setup()

    try:
        site = web.TCPSite(runner, port=8080)
        await site.start()

        notify_ready()

        print(
            f"======== Running on {site.name} ========\n"
            "(Press CTRL+C to quit)"
        )

        while True:
            await asyncio.sleep(3600)
    finally:
        await runner.cleanup()


def main():
    app = web.Application()
    app.add_routes([web.get('/', hello)])

    # app.on_startup.append(notify_ready)
    # web.run_app(app)

    loop = asyncio.new_event_loop()

    main_task = loop.create_task(run(app))

    try:
        asyncio.set_event_loop(loop)
        loop.run_until_complete(main_task)
    except (KeyboardInterrupt, web.GracefulExit):
        pass
    finally:
        main_task.cancel()
        loop.run_until_complete(loop.shutdown_asyncgens())
        loop.close()
        asyncio.set_event_loop(None)


if __name__ == '__main__':
    main()
