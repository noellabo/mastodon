import React from 'react';
import { connect } from 'react-redux';
import { changeReportComment, submitReport } from '../../../actions/reports';
import { refreshAccountTimeline } from '../../../actions/timelines';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { makeGetAccount } from '../../../selectors';
import { defineMessages, FormattedMessage, injectIntl } from 'react-intl';
import StatusCheckBox from '../../report/containers/status_check_box_container';
import Immutable, { OrderedSet } from 'immutable';
import Toggle from 'react-toggle';
import ImmutablePureComponent from 'react-immutable-pure-component';
import Button from '../../../components/button';

const messages = defineMessages({
  placeholder: { id: 'report.placeholder', defaultMessage: 'Additional comments' },
  submit: { id: 'report.submit', defaultMessage: 'Submit' },
  reportTitle: { id: 'report.select.title', defaultMessage: 'Please select the reason for reporting' },
  donotlike: { id: 'report.select.donotlike', defaultMessage: 'I do not like it' },
  incorrectage: { id: 'report.select.incorrectage', defaultMessage: 'Incorrect CW・NSFW setting' },
  spam: { id: 'report.select.spam', defaultMessage: 'Spam' },
  reproduction: { id: 'report.select.reproduction', defaultMessage: 'Unauthorized reproduction' },
  prohibited: { id: 'report.select.prohibited', defaultMessage: 'Prohibited act' },
});

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = state => {
    const accountId = state.getIn(['reports', 'new', 'account_id']);

    return {
      isSubmitting: state.getIn(['reports', 'new', 'isSubmitting']),
      account: getAccount(state, accountId),
      comment: state.getIn(['reports', 'new', 'comment']),
      statusIds: OrderedSet(state.getIn(['timelines', `account:${accountId}`, 'items'])).union(state.getIn(['reports', 'new', 'status_ids'])),
    };
  };

  return mapStateToProps;
};

@connect(makeMapStateToProps)
@injectIntl
export default class ReportModal extends ImmutablePureComponent {

  static propTypes = {
    isSubmitting: PropTypes.bool,
    account: ImmutablePropTypes.map,
    statusIds: ImmutablePropTypes.orderedSet.isRequired,
    comment: PropTypes.string.isRequired,
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  state = { option: false };
  options = Immutable.fromJS([
    { id: 'donotlike', value: '好みではない' },
    { id: 'incorrectage', value: 'CW・NSFW設定の不足' },
    { id: 'spam', value: 'スパム・迷惑行為' },
    { id: 'reproduction', value: '無断転載' },
    { id: 'prohibited', value: '禁止行為に該当' },
  ]);

  handleCommentChange = (e) => {
    this.props.dispatch(changeReportComment(e.target.value));
  }

  handleSubmit = () => {
    this.props.dispatch(submitReport());
  }

  handlePreSubmit = () => {
    this.setState({ option: true });
  }

  componentDidMount () {
    this.props.dispatch(refreshAccountTimeline(this.props.account.get('id')));
  }

  componentWillReceiveProps (nextProps) {
    if (this.props.account !== nextProps.account && nextProps.account) {
      this.props.dispatch(refreshAccountTimeline(nextProps.account.get('id')));
    }
  }

  onToggle = (e) => {
    this.props.dispatch(changeReportComment('')); // FIXME: Re render self
    this.props.dispatch(changeReportComment(e.target.getAttribute('name')));
  }

  render () {
    const { account, comment, intl, statusIds, isSubmitting } = this.props;
    const { option: visibleOption } = this.state;
    const filled = this.options.findIndex(option => option.get('value') === comment) > -1;

    if (!account) {
      return null;
    }

    return (
      <div className='modal-root__modal report-modal'>
        <div className='report-modal__target'>
          <FormattedMessage id='report.target' defaultMessage='Report {target}' values={{ target: <strong>{account.get('acct')}</strong> }} />
        </div>

        <div className='report-modal__container'>
          <div className='report-modal__statuses' style={{ display: visibleOption ? 'none': null }}>
            <div>
              {statusIds.map(statusId => <StatusCheckBox id={statusId} key={statusId} disabled={isSubmitting} />)}
            </div>
          </div>

          {visibleOption &&
            <div className='report-modal__comment'>
              <div className='report__select'>
                <div>
                  <div className='report__select__title'>{intl.formatMessage(messages.reportTitle)}</div>
                  {this.options.map(option => (
                    <div key={option.get('id')} style={{ display: 'flex' }}>
                      <div style={{ flex: '1 1 auto', padding: '10px' }}>
                        {intl.formatMessage(messages[option.get('id')])}
                      </div>
                      <div style={{ flex: '0 0 auto', padding: '10px', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
                        <Toggle name={option.get('value')} checked={this.props.comment === option.get('value')} onChange={this.onToggle} disabled={isSubmitting} />
                      </div>
                    </div>
                  ))}
                  <textarea
                    className={`setting-text light ${filled ? 'filled' : ''}`}
                    placeholder={intl.formatMessage(messages.placeholder)}
                    value={filled ? '' : comment}
                    onChange={this.handleCommentChange}
                    disabled={isSubmitting}
                  />
                </div>
              </div>
            </div>
          }
        </div>

        <div className='report-modal__action-bar'>
          <Button disabled={isSubmitting || (visibleOption && comment.length === 0)} text={intl.formatMessage(messages.submit)} onClick={visibleOption ? this.handleSubmit : this.handlePreSubmit} />
        </div>
      </div>
    );
  }

}
