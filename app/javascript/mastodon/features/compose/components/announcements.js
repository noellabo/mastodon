import React from 'react';
import Immutable from 'immutable';
import Link from 'react-router-dom/Link';
import IconButton from '../../../components/icon_button';

const storageKey = 'announcements_dismissed';

// NOTE: id: 15 まで使用した
const announcements = [
  {
    id: 1,
    icon: '/announcements/icon_2x_360.png',
    body: 'iOS・AndroidでもPawoo！Pawooアプリを使おう！',
    link: [
      {
        reactRouter: false,
        inline: true,
        href: 'https://itunes.apple.com/us/app/%E3%83%9E%E3%82%B9%E3%83%88%E3%83%89%E3%83%B3%E3%82%A2%E3%83%97%E3%83%AA-pawoo/id1229070679?l=ja&ls=1&mt=8',
        body: 'Appストア',
      }, {
        reactRouter: false,
        inline: true,
        href: 'https://play.google.com/store/apps/details?id=jp.pxv.pawoo&hl=ja',
        body: 'Google Playストア',
      },
    ],
  }, {
    id: 7,
    icon: '/announcements/icon_2x_360.png',
    body: 'Pawooにどんなユーザーさんがいるのか見てみよう！',
    link: [
      {
        reactRouter: true,
        inline: false,
        href: '/suggested_accounts',
        body: 'おすすめユーザー（実験中）',
      },
    ],
  },
];

class Announcements extends React.PureComponent {

  constructor (props, context) {
    super(props, context);

    try {
      const dismissed = JSON.parse(localStorage.getItem(storageKey));
      this.state = { dismissed: Array.isArray(dismissed) ? dismissed : [] };
    } catch (e) {
      this.state = { dismissed: [] };
    }

    this.announcements = Immutable.fromJS(announcements);
  }

  componentDidUpdate (prevProps, prevState) {
    if (prevState.dismissed !== this.state.dismissed) {
      try {
        localStorage.setItem(storageKey, JSON.stringify(this.state.dismissed));
      } catch (e) {}
    }
  }

  handleDismiss = (event) => {
    const id = +event.currentTarget.getAttribute('title');

    if (Number.isInteger(id)) {
      this.setState({ dismissed: [].concat(this.state.dismissed, id) });
    }
  }

  render () {
    return (
      <ul className='announcements'>
        {this.announcements.map(announcement => this.state.dismissed.indexOf(announcement.get('id')) === -1 && (
          <li key={announcement.get('id')}>
            <div className='announcements__icon'>
              <img src={announcement.get('icon')} alt='' />
            </div>
            <div className='announcements__body'>
              <div className='announcements__body__dismiss'>
                <IconButton icon='close' title={`${announcement.get('id')}`} onClick={this.handleDismiss} />
              </div>
              <p>{announcement.get('body')}</p>
              <p>
                {announcement.get('link').map((link) => {
                  const classNames = ['announcements__link'];
                  const action = link.get('action');

                  if (link.get('inline')) {
                    classNames.push('announcements__link-inline');
                  }

                  if (link.get('reactRouter')) {
                    return (
                      <Link key={link.get('href')} className={classNames.join(' ')} to={link.get('href')} onClick={action ? action : null}>
                        {link.get('body')}
                      </Link>
                    );
                  } else {
                    return (
                      <a className={classNames.join(' ')} key={link.get('href')} href={link.get('href')} target='_blank' onClick={action ? action : null}>
                        {link.get('body')}
                      </a>
                    );
                  }
                })}
              </p>
            </div>
          </li>
        ))}
      </ul>
    );
  }

};

export default Announcements;
