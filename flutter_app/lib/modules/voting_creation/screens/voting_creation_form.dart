import 'package:algorand_dart/algorand_dart.dart';
import 'package:algorand_evoting/config/themes/themes.dart';
import 'package:algorand_evoting/modules/voting_creation/models/models.dart';
import 'package:algorand_evoting/utils/helpers/date_extension.dart';
import 'package:algorand_evoting/modules/voting_creation/voting_creation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

class VotingCreationForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<VotingCreationBloc, VotingCreationState>(
      listener: (context, state) {
        if (state.status.isSubmissionFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Creation Failure')),
            );
        }
        if (state.status.isSubmissionSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Creation Success')),
            );
          Navigator.of(context).pop(true);
        }
      },
      child: Align(
        alignment: const Alignment(0, -1 / 3),
        child: ListView(
          children: [
            _TitleInput(),
            const Padding(padding: EdgeInsets.all(5)),
            _DescriptionInput(),
            const Padding(padding: EdgeInsets.all(12)),
            _OptionOneInput(),
            const Padding(padding: EdgeInsets.all(5)),
            _OptionTwoInput(),
            const Padding(padding: EdgeInsets.all(12)),
            _AssetSelection(),
            const Padding(padding: EdgeInsets.all(12)),
            _RegBeginDate(),
            _RegEndDate(),
            _VoteBeginDate(),
            _VoteEndDate(),
            const Padding(padding: EdgeInsets.all(12)),
            _SubmitButton(),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VotingCreationBloc, VotingCreationState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const Center(child: const CircularProgressIndicator())
            : ElevatedButton(
                key: const Key('creationForm_continue_raisedButton'),
                child: const Text('Create voting'),
                onPressed: state.status.isValidated
                    ? () {
                        context
                            .read<VotingCreationBloc>()
                            .add(const VotingCreationSubmitted());
                      }
                    : () {
                        String message = '';
                        message +=
                            state.title.valid ? '' : 'title is invalid\n';
                        message += state.description.valid
                            ? ''
                            : 'description is invalid\n';
                        message +=
                            state.assetId.valid ? '' : 'asset is invalid\n';
                        message +=
                            state.optionOne.valid ? '' : 'optOne is invalid\n';
                        message +=
                            state.optionTwo.valid ? '' : 'optTwo is invalid\n';
                        message +=
                            state.regBegin.valid ? '' : 'regBegin is invalid\n';
                        message +=
                            state.regEnd.valid ? '' : 'regEnd is invalid\n';
                        message += state.voteBegin.valid
                            ? ''
                            : 'voteBegin is invalid\n';
                        message +=
                            state.voteEnd.valid ? '' : 'voteEnd  invalid';
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(SnackBar(
                            duration: Duration(seconds: 1),
                            content: Text(message),
                          ));
                      },
              );
      },
    );
  }
}

class _AssetSelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Asset>? availableAssets =
        context.select((VotingCreationBloc bloc) => bloc.state.availableAssets);
    return BlocBuilder<VotingCreationBloc, VotingCreationState>(
      buildWhen: (previous, current) =>
          previous.assetId != current.assetId ||
          previous.availableAssets != current.availableAssets,
      builder: (context, state) {
        return DropdownButtonFormField(
          hint: Text('Asset id'),
          key: const Key('voteCreation_assetIdInput_DropdownField'),
          onChanged: (Asset? assetId) => context
              .read<VotingCreationBloc>()
              .add(VotingCreationAssetIdChanged(assetId)),
          items: availableAssets?.map<DropdownMenuItem<Asset>>((Asset asset) {
            return DropdownMenuItem<Asset>(
              value: asset,
              child: Text(asset.params.name ?? asset.index.toString()),
            );
          }).toList(),
        );
      },
    );
  }
}

class _VoteEndDate extends StatelessWidget {
  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      helpText: 'Select voting end date',
    );
    if (picked != null) {
      DateTime thisMoment = DateTime.now();
      if (picked.isSameDate(thisMoment)) {
        TimeOfDay time = TimeOfDay.now();
        int minutes = (time.minute + 1) % TimeOfDay.minutesPerHour;
        int delta = ((time.minute + 1) / TimeOfDay.minutesPerHour).floor();
        int hours = time.hour + delta;
        final validDate =
            DateTime(picked.year, picked.month, picked.day, hours, minutes);
        context
            .read<VotingCreationBloc>()
            .add(VotingCreationVoteEndChanged(validDate));
      } else {
        context
            .read<VotingCreationBloc>()
            .add(VotingCreationVoteEndChanged(picked));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VotingCreationBloc, VotingCreationState>(
      buildWhen: (previous, current) =>
          previous.voteEnd.value != current.voteEnd.value,
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                onPressed: () => _selectDate(context), // Refer step 3
                child: Text(
                  'Select voting end date',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "${state.voteEnd.value?.toLocal()}".split(' ')[0],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _VoteBeginDate extends StatelessWidget {
  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      helpText: 'Select voting begin date',
    );
    if (picked != null) {
      DateTime thisMoment = DateTime.now();
      if (picked.isSameDate(thisMoment)) {
        TimeOfDay time = TimeOfDay.now();
        int minutes = (time.minute + 1) % TimeOfDay.minutesPerHour;
        int delta = ((time.minute + 1) / TimeOfDay.minutesPerHour).floor();
        int hours = time.hour + delta;
        final validDate =
            DateTime(picked.year, picked.month, picked.day, hours, minutes);
        context
            .read<VotingCreationBloc>()
            .add(VotingCreationVoteBeginChanged(validDate));
      } else {
        context
            .read<VotingCreationBloc>()
            .add(VotingCreationVoteBeginChanged(picked));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VotingCreationBloc, VotingCreationState>(
      buildWhen: (previous, current) =>
          previous.voteBegin.value != current.voteBegin.value,
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                onPressed: () => _selectDate(context), // Refer step 3
                child: Text(
                  'Select voting begin date',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "${state.voteBegin.value?.toLocal()}".split(' ')[0],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RegEndDate extends StatelessWidget {
  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      helpText: 'Select registration end date',
    );
    if (picked != null) {
      DateTime thisMoment = DateTime.now();
      if (picked.isSameDate(thisMoment)) {
        TimeOfDay time = TimeOfDay.now();
        int minutes = (time.minute + 1) % TimeOfDay.minutesPerHour;
        int delta = ((time.minute + 1) / TimeOfDay.minutesPerHour).floor();
        int hours = time.hour + delta;
        final validDate =
            DateTime(picked.year, picked.month, picked.day, hours, minutes);
        context
            .read<VotingCreationBloc>()
            .add(VotingCreationRegEndChanged(validDate));
      } else {
        context
            .read<VotingCreationBloc>()
            .add(VotingCreationRegEndChanged(picked));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VotingCreationBloc, VotingCreationState>(
      buildWhen: (previous, current) =>
          previous.regEnd.value != current.regEnd.value,
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                onPressed: () => _selectDate(context), // Refer step 3
                child: Text(
                  'Select registration end date',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "${state.regEnd.value?.toLocal()}".split(' ')[0],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RegBeginDate extends StatelessWidget {
  _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      helpText: 'Select registration begin date',
    );
    if (picked != null) {
      DateTime thisMoment = DateTime.now();
      if (picked.isSameDate(thisMoment)) {
        TimeOfDay time = TimeOfDay.now();
        int minutes = (time.minute + 1) % TimeOfDay.minutesPerHour;
        int delta = ((time.minute + 1) / TimeOfDay.minutesPerHour).floor();
        int hours = time.hour + delta;
        final validDate =
            DateTime(picked.year, picked.month, picked.day, hours, minutes);
        context
            .read<VotingCreationBloc>()
            .add(VotingCreationRegBeginChanged(validDate));
      } else {
        context
            .read<VotingCreationBloc>()
            .add(VotingCreationRegBeginChanged(picked));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VotingCreationBloc, VotingCreationState>(
      buildWhen: (previous, current) =>
          previous.regBegin.value != current.regBegin.value,
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                onPressed: () => _selectDate(context), // Refer step 3
                child: Text(
                  'Select registration begin date',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "${state.regBegin.value?.toLocal()}".split(' ')[0],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TitleInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VotingCreationBloc, VotingCreationState>(
      buildWhen: (previous, current) => previous.title != current.title,
      builder: (context, state) {
        return TextField(
          key: const Key('voteCreation_titleInput_textField'),
          onChanged: (title) => context
              .read<VotingCreationBloc>()
              .add(VotingCreationTitleChanged(title)),
          decoration: InputDecoration(
            labelText: 'title',
            errorText: state.title.invalid ? 'invalid title' : null,
          ),
        );
      },
    );
  }
}

class _DescriptionInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VotingCreationBloc, VotingCreationState>(
      buildWhen: (previous, current) =>
          previous.description != current.description,
      builder: (context, state) {
        return TextField(
          key: const Key('voteCreation_descriptionInput_textField'),
          onChanged: (description) => context
              .read<VotingCreationBloc>()
              .add(VotingCreationDescriptionChanged(description)),
          decoration: InputDecoration(
            labelText: 'description',
            errorText: state.description.invalid ? 'invalid description' : null,
          ),
        );
      },
    );
  }
}

class _OptionOneInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VotingCreationBloc, VotingCreationState>(
      buildWhen: (previous, current) => previous.optionOne != current.optionOne,
      builder: (context, state) {
        return TextField(
          key: const Key('voteCreation_optionOneInput_textField'),
          onChanged: (optionOne) => context
              .read<VotingCreationBloc>()
              .add(VotingCreationOptOneChanged(optionOne)),
          decoration: InputDecoration(
            labelText: 'option one',
            errorText: state.description.invalid ? 'invalid option one' : null,
          ),
        );
      },
    );
  }
}

class _OptionTwoInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VotingCreationBloc, VotingCreationState>(
      buildWhen: (previous, current) => previous.optionTwo != current.optionTwo,
      builder: (context, state) {
        return TextField(
          key: const Key('voteCreation_optionTwoInput_textField'),
          onChanged: (optionTwo) => context
              .read<VotingCreationBloc>()
              .add(VotingCreationOptTwoChanged(optionTwo)),
          decoration: InputDecoration(
            labelText: 'option two',
            errorText: state.description.invalid ? 'invalid option two' : null,
          ),
        );
      },
    );
  }
}
