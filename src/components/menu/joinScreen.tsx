import { useState } from "react";
import { User } from "../../assets/types";

export default function JoinScreen(props: {
    joinViaCode: () => void;
   
    fbUser: User | undefined;
    disabled: boolean;
    name: string;
    addr: string;
    SetAddress: React.Dispatch<React.SetStateAction<string>>;
    SetName: React.Dispatch<React.SetStateAction<string>>;
}) {
 
    return (
        <>
          
          
          <>
                    <div key={"online-code"}>
                        <p>please enter your code:</p>
                        <input
                            type="text"
                            id="name"
                            onChange={(e) => props.SetAddress(e.currentTarget.value)}
                            defaultValue={props.addr}
                            placeholder="enter code"
                        />
                    </div>

                    <div key={"online-name"}>
                        <p>please enter your name:</p>
                        {props.fbUser === undefined ? (
                            <input
                                type="text"
                                id="name"
                                onChange={(e) => {
                                    props.SetName(e.currentTarget.value);
                                }}
                                defaultValue={props.name}
                                placeholder="enter name"
                            />
                        ) : (
                            <input type="text" id="name" disabled={true} value={props.name} placeholder="enter name" />
                        )}
                    </div>

                    <center>
                        <button
                            onClick={() => {
                                props.joinViaCode();
                            }}
                            disabled={props.disabled}
                        >
                            join
                        </button>
                    </center>
                </>
        </>
    );
}
