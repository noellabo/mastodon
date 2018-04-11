import React from 'react';
import ImmutablePureComponent from 'react-immutable-pure-component';

import artboard1 from '../images/first_anniversary/artboard_1.png';
import artboard2 from '../images/first_anniversary/artboard_2.png';
import artboard3 from '../images/first_anniversary/artboard_3.png';

const april11 = 1523372400000;
const april12 = 1523458800000;
const april13 = 1523545200000;
const april14 = 1523631600000;

export default class FirstAnniversaryBanner extends ImmutablePureComponent {

  state = {
    now: Math.floor((new Date()).getTime()),
  }

  componentDidMount () {
    this.timer = setInterval(() => {
      this.setState({
        now: Math.floor((new Date()).getTime()),
      });
    }, 10 * 60 * 1000);
  }

  componentWillUnmount () {
    if (this.timer) {
      clearInterval(this.timer);
    }
  }

  render () {
    const { now } = this.state;

    let image = null;
    let url = null;

    if (now >= april11 && now < april12) {
      image = artboard3;
    } else if (now >= april12 && now < april13) {
      image = artboard2;
    } else if (now >= april13 && now < april14) {
      image = artboard1;
    } else if (now >= april14) {
      // NOTE: 月曜日にはこのバナーを消してお知らせで表示
      // TODO: 画像とURLの設定
    }

    return (
      <div className={'pawoo-first-anniversary-banner'}>
        {url ? (
          <a href={url} target='_blank'>
            <img src={image} />
          </a>
        ) : (
          <img src={image} />
        )}
      </div>
    );
  }

}
