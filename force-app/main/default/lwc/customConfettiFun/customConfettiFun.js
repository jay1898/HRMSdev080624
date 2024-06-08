import { LightningElement } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import CONFETTI from "@salesforce/resourceUrl/Confetti2";

export default class CustomConfettiFun extends LightningElement {
    myconfetti;

    setUpCanvas() {
        var confettiCanvas = this.template.querySelector("canvas.confettiCanvas");
        this.myconfetti = confetti.create(confettiCanvas, { resize: true });
        this.myconfetti({
            zIndex: 10000
        });
    }

    basicCongo() {
        Promise.all([
            loadScript(this, CONFETTI),
        ]).then(() => {
            // this.dispatchEvent(
            //     new ShowToastEvent({
            //         title: "Success",
            //         message: "Dependencies loaded successfully",
            //         variant: "Success"
            //     })
            // );
            this.setUpCanvas();

            this.burst();
            this.fireworks();
            this.basicCannon();

        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: error.message,
                    variant: error
                })
            );
        });
    }

    basicCannon() {

        //Call another
        setTimeout(() => {
            this.burst();
        }, 1000);

        confetti({
            particleCount: 100,
            spread: 70,
            origin: {
                y: 0.6
            }
        });
    }

    fireworks() {
        var end = Date.now() + 15 * 1000;

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        let interval = setInterval(function () {
            if (Date.now() > end) {
                return clearInterval(interval);
            }

            // eslint-disable-next-line no-undef
            confetti({
                startVelocity: 30,
                spread: 360,
                ticks: 60,
                origin: {
                    x: Math.random(),
                    // since they fall down, start a bit higher than random
                    y: Math.random() - 0.2
                }
            });
        }, 200);
    }

    shower() {
        //Call another
        setTimeout(() => {
            this.celebration();
        }, 1000);

        var end = Date.now() + (15 * 100);
        (function frame() {
            confetti({
                particleCount: 10,
                startVelocity: 0,
                ticks: 300,
                origin: {
                    x: Math.random(),
                    y: 0
                },
            });
            if (Date.now() < end) {
                requestAnimationFrame(frame);
            }
        }());
    }

    celebration() {
        var end = Date.now() + (15 * 100);

        confetti({
            particleCount: 10,
            angle: 60,
            spread: 25,
            origin: {
                x: 0,
                y: 0.65
            },
        });
        confetti({
            particleCount: 10,
            angle: 120,
            spread: 25,
            origin: {
                x: 1,
                y: 0.65
            },
        });
        if (Date.now() < end) {
            requestAnimationFrame(frame);
        }
    }

    burst() {
        //Call Another
        setTimeout(() => {
            this.fireworks();
        }, 1000);

        var end = Date.now() + (15 * 75);
        //These are four diffrent confetti in frour diffrent corner
        (function frame() {
            // #1
            confetti({
                particleCount: 7,
                startVelocity: 25,
                angle: 335,
                spread: 10,
                origin: {
                    x: 0,
                    y: 0,
                },
            });
            // #2
            confetti({
                particleCount: 7,
                startVelocity: 25,
                angle: 205,
                spread: 10,
                origin: {
                    x: 1,
                    y: 0,
                },
            });
            // #3
            confetti({
                particleCount: 7,
                startVelocity: 35,
                angle: 140,
                spread: 30,
                origin: {
                    x: 1,
                    y: 1,
                },
            });
            // #4
            confetti({
                particleCount: 7,
                startVelocity: 35,
                angle: 40,
                spread: 30,
                origin: {
                    x: 0,
                    y: 1,
                },
            });
            if (Date.now() < end) {
                requestAnimationFrame(frame);
            }
        }());
    }
}