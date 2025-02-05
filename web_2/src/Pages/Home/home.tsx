import { useState, useRef, useEffect } from "react";
import Monopoly from "./monopoly.tsx";
import "../../Styling/home.css";
import { Server, Socket, io } from "../../assets/sockets.ts";
import NotifyElement, { NotificatorRef } from "../../components/notificator.tsx";
import { MonopolyCookie, User, botInitial } from "../../assets/types.ts";
import SettingsNav from "../../components/settingsNav.tsx";
import JoinScreen from "../../components/menu/joinScreen.tsx";
import { main as onlineServer } from "../../assets/server.ts";
import Slider from "../../components/utils/slider.tsx";
import { TranslateCode } from "../../assets/code.env.ts";
import {CookieManager} from "../../assets/cookieManager.ts";

export default function Home() {
    var cookie: MonopolyCookie;
    try {
        const getCookieString = CookieManager.get("monopolySettings");
        if (getCookieString === null) throw new Error("no cookie");
        const obj = JSON.parse(decodeURIComponent(getCookieString));
        cookie = obj;
    } catch {
        cookie = {
            login: {
                remember: false,
                id: "",
            },
        } as MonopolyCookie;

        CookieManager.set("monopolySettings", encodeURIComponent(JSON.stringify(cookie as MonopolyCookie)));
    }

    const notifyRef = useRef<NotificatorRef>(null);
    const [socket, SetSocket] = useState<Socket>();
    // Gameplay stuff
    const [name, SetName] = useState<string>("");
    const [addr, SetAddress] = useState<string>("");

    // Account stuff
    // const [firebase, setFirebase] = useState<FirebaseApp>();
    const [
        remember,
        // @ts-ignore
        SetRemember,
    ] = useState<boolean>(cookie.login.remember);
    const [
        fbUser,
        // @ts-ignore
        SetFbUser,
    ] = useState<User>();

    const [disabled, SetDisabled] = useState<boolean>(false);
    const [isSignedIn, SetSignedIn] = useState<boolean>(false);
    const [tabIndex, SetTab] = useState<number>(0);

    // Server Stuff
    const [server, SetServer] = useState<Server | undefined>(undefined);
    const [serverPCount, SetServerPCount] = useState<number>(6);

    useEffect(() => {
        document.title = "Monopoly";
        // const _firebase = initializeApp(ENV.firebase);
        // setFirebase(_firebase);
        var cookie: MonopolyCookie;
        try {
            const obj = JSON.parse(decodeURIComponent(CookieManager.get("monopolySettings") as string));
            cookie = obj;
            if (cookie.login.remember && cookie.login.id.length > 0) {
                // const db = getFirestore(_firebase);
                // getDoc(doc(db, `Users/${cookie.login.id}`)).then((v) => {
                //     const userData = v.data() as User;
                //     SetFbUser(userData);
                //     SetName(userData.name);
                // });
            }
        } catch {}
    }, []);

    const joinButtonClicked = async () => {
        if (name.replace(" ", "").length === 0) {
            notifyRef.current?.message("please add your name before joining", "info", 2);
            return;
        }

        try {
            const cookie = JSON.parse(decodeURIComponent(CookieManager.get("monopolySettings") as string)) as MonopolyCookie;
            if (fbUser === undefined) throw Error("undefined");

            cookie.login = {
                id: fbUser.id,
                remember,
            };

            CookieManager.set("monopolySettings", encodeURIComponent(JSON.stringify(cookie as MonopolyCookie)));
        } catch {
            const cookie = {
                login: {
                    id: "",
                    remember: false,
                },
            } as MonopolyCookie;
            CookieManager.set("monopolySettings", encodeURIComponent(JSON.stringify(cookie as MonopolyCookie)));
        }
        SetDisabled(true);

        const address = TranslateCode(addr) as string;
        var socket: Socket;
        // const address = "localhost"
        try {
            socket = await io(address);

            socket.on("state", (args: number) => {
                console.log("state");
                switch (args) {
                    case 0:
                        SetSocket(socket);
                        SetSignedIn(true);
                        SetDisabled(false);
                        break;
                    case 1:
                        notifyRef.current?.message("the game has already begun", "error", 2, () => {
                            SetDisabled(false);
                        });
                        socket.disconnect();
                        break;
                    case 2:
                        notifyRef.current?.message("too many players on the server", "error", 2, () => {
                            SetDisabled(false);
                        });
                        socket.disconnect();
                        break;
                    default:
                        notifyRef.current?.message("unkown error", "error", 2, () => {
                            SetDisabled(false);
                        });
                        socket.disconnect();

                        break;
                }
            });
        } catch (r) {
            notifyRef.current?.message(`Could not connect to peer ${addr}`, "error", 2, () => {
                SetDisabled(false);
            });
        }
    };

    useEffect(() => {
        const uriParams = new URLSearchParams(document.location.search);
        if (uriParams.has("ip")) {
            SetAddress(uriParams.get("ip") ?? "");
        }
    }, []);

    function startButtonClicked(bots: botInitial[]) {
        try {
            if (name.replace(" ", "").length === 0) {
                notifyRef.current?.message("please add your name before joining", "info", 2);
                return;
            }

           
        } catch {
            SetDisabled(false);
        }
    }

    return socket !== undefined && isSignedIn === true ? (
        <Monopoly socket={socket} name={name} server={server} />
    ) : (
        <>
            <NotifyElement ref={notifyRef} />
            <div className="entry">
            <nav >
                    <button 
                        data-select={tabIndex === 0}
                        onClick={() => {
                            SetTab(0);
                        }}
                        data-tooltip-hover="Play"
                    >
                        <img src="./icon.png" alt="" />
                    </button>
                    <button
                        data-select={tabIndex === 1}
                        onClick={() => {
                            SetTab(1);
                        }}
                        data-tooltip-hover="Server"
                    >
                        <img src="./server.png" alt="" />
                    </button>
                  
               
                  
                    <button              data-select={tabIndex === 4}
                        onClick={() => {
                            SetTab(4);
                        }}
                        data-tooltip-hover="Settings"
                    >
                        <img src="./settings.png" alt="" />
                    </button>
                </nav>
                <main>
                    {tabIndex === 4 ? (
                      <SettingsNav />
                    )  :
                    tabIndex === 1 ? (
                        <>
                            <header>
                                <p
                                    style={{
                                        fontSize: 12,
                                        marginBottom: 0,
                                    }}
                                >
                                  
                                </p>
                                <h3>Run A Server</h3>
                            </header>
                            {server !== undefined ? (
                                <>
                                    <p>server is already running, check the console.</p>
                                    <table>
                                        <tr>
                                            <td>Code</td>
                                            <td style={{ userSelect: "all" }}>{server.code}</td>
                                        </tr>
                                    </table>
                                    <center>
                                        {" "}
                                        <button
                                            key={"kllserver-button"}
                                            style={{
                                                backgroundColor: "red",
                                                marginTop: 12,
                                            }}
                                            onClick={() => {
                                                server.stop();
                                                SetServer(undefined);
                                            }}
                                        >
                                            Kill Server
                                        </button>
                                    </center>
                                </>
                            ) : (
                                <>
                                    <p>all the servers logs will can be seen in the console</p>
                                    <table>
                                        <tr>
                                            <td>PlayersCount</td>
                                            <td>
                                                <Slider
                                                    onChange={(e) => {
                                                        SetServerPCount(parseInt(e.currentTarget.value));
                                                    }}
                                                    max={6}
                                                    min={1}
                                                    defaultValue={serverPCount}
                                                    step={1}
                                                />
                                            </td>
                                        </tr>
                                    </table>
                                    <center>
                                        {" "}
                                        <button
                                            key={"startserver-button"}
                                            style={{
                                                marginTop: 13,
                                            }}
                                            onClick={(e) => {
                                                e.currentTarget.disabled = true;
                                                e.currentTarget.innerHTML = "Starting Server";
                                                onlineServer(serverPCount, (host, server) => {
                                                    server.code = host;
                                                    SetAddress(host);
                                                    SetServer(server);
                                                    try {
                                                        e.currentTarget.disabled = false;
                                                    } catch {}
                                                });
                                            }}
                                        >
                                            Run Server
                                        </button>
                                    </center>
                                </>
                            )}
                        </>
                    ) : (
                        <>
                            <header>
                                Welcome to the <h3>MONOPOLY</h3>{" "}
                                <p
                                    style={{ fontSize: 9, cursor: "pointer", opacity: 0.8, width: "fit-content" }}
                                    onClick={() => {
                                        document.location.href = "/";
                                    }}
                                >
                                   
                                </p>{" "}
                                Game
                            </header>
                            <JoinScreen
                                disabled={disabled}
                                fbUser={fbUser}
                                joinViaCode={() => {
                                    joinButtonClicked();
                                }}
                                SetAddress={SetAddress}
                                SetName={SetName}
                                addr={addr}
                                name={name}
                            />
                        </>
                    )}
                </main>
            </div>
        </>
    );
}
